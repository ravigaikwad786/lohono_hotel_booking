class VillasController < ApplicationController
   HIGH_DEMAND_DATES = [
    Date.new(2025, 12, 24), 
    Date.new(2025, 12, 31), 
    Date.new(2025, 7, 4),
  ].freeze

  def index
    start_date = params[:check_in_date].to_date
    end_date = params[:check_out_date].to_date
    sort_by = params[:sort_by]
    
    villas = Villa
	  .joins(:villa_schedules)
	  .where('villa_schedules.date >= ? AND villa_schedules.date < ?', start_date, end_date)
	  .group('villas.id')
	  .select('villas.*, AVG(villa_schedules.price) AS avg_price,
	           BOOL_AND(villa_schedules.available) AS available')
	

  villas = if sort_by == 'price'
	           villas.order('avg_price ASC')
	         elsif sort_by == 'availability'
	           villas.order('available DESC')
	         else
	           villas
	         end

    render json: villas
  end

  def calculate_dynamic_rate
   villa = Villa.includes(:villa_schedules).find_by(id: params[:villa_id])
    return render json: { error: "Villa not found" }, status: :not_found unless villa

    start_date = params[:check_in_date].to_date
    end_date = params[:check_out_date].to_date
    nights = villa.villa_schedules.where(date: start_date...end_date).pluck(:available, :price, :date)

    available = nights.all? { |n| n[0] }
    return render json: { available: false, total_price: nil } unless available

    base_price = nights.sum { |n| n[1] }

    demand_factor = calculate_demand_factor(start_date, end_date)
    seasonal_factor = seasonal_adjustment(start_date, end_date)
    booking_window_factor = booking_window_adjustment(start_date)
    high_demand_factor = high_demand_adjustment(nights.map { |n| n[2] })

    total_price = base_price * demand_factor * seasonal_factor * booking_window_factor * high_demand_factor * 1.18

    render json: { available: available, total_price: total_price.round(2) }
  end

  def calculate_rate
    begin
      villa = Villa.find(params[:villa_id])
    rescue ActiveRecord::RecordNotFound
      return render json: { error: "Villa not found" }, status: :not_found 
    end
    start_date = params[:check_in_date].to_date
    end_date = params[:check_out_date].to_date
    
    nights = villa.villa_schedules.where(date: start_date...end_date).pluck(:available, :price)

    available = nights.all?(&:available)
    total_price = nights.sum(&:price) * 1.18 if available
    
    render json: { available: available, total_price: total_price }
  end

  private

  def calculate_demand_factor(start_date, end_date)
    total_villas = Villa.count
    booked_villas = Villa.joins(:villa_schedules)
                         .where('villa_schedules.date >= ? AND villa_schedules.date < ?', start_date, end_date)
                         .where.not(villa_schedules: { available: true })
                         .distinct.count

    occupancy_rate = booked_villas.to_f / total_villas

    if occupancy_rate > 0.8
      1.2
    elsif occupancy_rate < 0.4
      0.9
    else
      1.0
    end
  end

  def seasonal_adjustment(start_date, end_date)
    peak_seasons = [5, 6, 12] # May, June, December (holiday months)
    is_weekend = (start_date..end_date).any? { |date| date.saturday? || date.sunday? }
    is_peak_season = (start_date.month..end_date.month).any? { |month| peak_seasons.include?(month) }

    if is_weekend || is_peak_season
      1.15 
    else
      0.9 
    end
  end

  def booking_window_adjustment(start_date)
    days_until_check_in = (start_date - Date.today).to_i

    if days_until_check_in <= 2
      0.85 
    elsif days_until_check_in >= 21
      1.1 
    else
      1.0 
    end
  end

  def high_demand_adjustment(dates)
    dates.any? { |date| HIGH_DEMAND_DATES.include?(date) } ? 1.11 : 1.0
  end
end
