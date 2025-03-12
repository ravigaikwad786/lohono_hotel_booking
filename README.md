# Villa Booking API

## **Project Setup Guide**

### **Requirements:**
- Ruby `3.2.2`
- Rails `7.1.5.1`
- PostgreSQL

### **Setup Instructions:**

1. **Clone the Repository:**
   ```sh
   git clone <repository_url>
   cd lohono_hotel_booking
   ```

2. **Install Dependencies:**
   ```sh
   bundle install
   ```

3. **Configure Database:**
   Update `config/database.yml` with PostgreSQL credentials.

4. **Setup the Database:**
   ```sh
   rails db:create db:migrate db:seed
   ```

5. **Start the Server:**
   ```sh
   rails server
   ```
   The API will be available at `http://localhost:3000/`

---
## **API Endpoints**

### **1. List Villas (Sorted by Price & Availability)**
#### **Endpoint:**
   ```http
   GET /villas
   ```

#### **Example Request:**
   ```http
   GET /villas?start_date=2025-01-01&end_date=2025-01-05&sort_by=price
   ```
#### **Example Response:**
   ```json
   [
     {
       "id": 1,
       "name": "Luxury Beachfront Villa",
       "avg_price": 39000.5,
       "available": true
     },
     {
       "id": 2,
       "name": "Mountain Escape Lodge",
       "avg_price": 43000.7,
       "available": false
     }
   ]
   ```

### **2. Calculate Total Price for a Villa**
#### **Endpoint:**
   ```http
   GET /villas/calculate_rate
   ```
#### **Example Request:**
   ```http
   GET /villas/calculate_rate?villa_id=1&check_in_date=2025-01-01&check_out_date=2025-01-05
   ```
#### **Example Response:**
   ```json
   {
     "available": true,
     "total_price": 248500.0
   }
   ```

---
## **Business Logic**
1. A villa is only available if **all nights** within the requested stay range are available.
2. If sorting by `availability`, available villas will be listed first.
3. The total price includes **18% GST** over the sum of nightly rates.

---
## **Notes**
- Ensure PostgreSQL is running before starting the app.
- Use `sort_by=price` for price-based sorting and `sort_by=availability` to prioritize available villas.
