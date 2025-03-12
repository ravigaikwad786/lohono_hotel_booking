class VillasController < ApplicationController
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

  def calculate_rate
    villa = Villa.find(params[:villa_id])
    start_date = params[:check_in_date].to_date
    end_date = params[:check_out_date].to_date
    
    nights = villa.villa_schedules.where(date: start_date...end_date)
    available = nights.all?(&:available)
    total_price = nights.sum(&:price) * 1.18 if available
    
    render json: { available: available, total_price: total_price }
  end

  def show_data
  	villa = Villa.all
  	villa_schedule = VillaSchedule.all
    render json: {message: "working find", villas: villa, schedule: villa_schedule}
  end
end
