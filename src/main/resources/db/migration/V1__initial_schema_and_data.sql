-- ########## 1. Lookup Tables (الجداول المرجعية) ##########

-- جدول الأقسام الحكومية
CREATE TABLE departments (
                             id BIGSERIAL PRIMARY KEY,
                             name VARCHAR(100) UNIQUE NOT NULL
);

-- جدول الأدوار
CREATE TABLE roles (
                       id BIGSERIAL PRIMARY KEY,
                       name VARCHAR(50) UNIQUE NOT NULL -- 'CITIZEN', 'EMPLOYEE', 'MANAGER'
);


-- جدول الخدمات (مربوط بالأقسام)
CREATE TABLE services (
                          id BIGSERIAL PRIMARY KEY,
                          department_id BIGINT NOT NULL REFERENCES departments(id),
                          name VARCHAR(200) NOT NULL,
                          description TEXT
);


-- ########## 2. Core Tables (الجداول الأساسية) ##########

-- جدول المستخدمين (المدمج للمواطنين والموظفين)
CREATE TABLE users (
                       id BIGSERIAL PRIMARY KEY,
                       national_id VARCHAR(14) UNIQUE NOT NULL,
                       password VARCHAR(255) NOT NULL,
                       full_name VARCHAR(100) NOT NULL,
                       email VARCHAR(100) UNIQUE,
                       phone_number VARCHAR(15),
                       address VARCHAR(300),
                       role_id BIGINT NOT NULL REFERENCES roles(id),
    -- Employee specific fields
                       job_role_code VARCHAR(50),
                       department_id BIGINT REFERENCES departments(id),
                       created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- التأكد من أن الموظف فقط هو من له قسم
                       CONSTRAINT check_employee_department CHECK ( (role_id != 1 AND department_id IS NOT NULL) OR (role_id = 1 AND department_id IS NULL) )
);

-- جدول طلبات الخدمات
CREATE TABLE service_requests (
                                  id BIGSERIAL PRIMARY KEY,
                                  citizen_id BIGINT NOT NULL REFERENCES users(id),
                                  service_id BIGINT NOT NULL REFERENCES services(id),
                                  status VARCHAR(50) NOT NULL,
                                  service_name VARCHAR(255) NOT NULL,
                                  department VARCHAR(255) NOT NULL,
                                  details TEXT,
                                  submission_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
                                  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


-- ########## 3. Supporting Tables (الجداول الداعمة) ##########

-- جدول المستندات المرفقة بالطلب
CREATE TABLE documents (
                           id BIGSERIAL PRIMARY KEY,
                           request_id BIGINT NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
                           document_type VARCHAR(100),
                           file_path VARCHAR(500) NOT NULL,
                           uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول المدفوعات
CREATE TABLE payments (
                          id BIGSERIAL PRIMARY KEY,
                          request_id BIGINT NOT NULL REFERENCES service_requests(id),
                          amount NUMERIC(10, 2) NOT NULL,
                          payment_status VARCHAR(50) DEFAULT 'Completed', -- e.g., 'Pending', 'Completed', 'Failed'
                          transaction_id VARCHAR(100),
                          created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول تعليقات الموظفين على الطلب
CREATE TABLE request_comments (
                                  id BIGSERIAL PRIMARY KEY,
                                  request_id BIGINT NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
                                  employee_id BIGINT NOT NULL REFERENCES users(id),
                                  comment TEXT NOT NULL,
                                  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- جدول المركبات (مملوكة للمواطنين)
CREATE TABLE vehicles (
                          id BIGSERIAL PRIMARY KEY,
                          citizen_id BIGINT NOT NULL REFERENCES users(id),
                          plate_number VARCHAR(50) UNIQUE NOT NULL,
                          vehicle_type VARCHAR(50)
);

-- جدول الإشعارات
CREATE TABLE notifications (
                               id BIGSERIAL PRIMARY KEY,
                               user_id BIGINT NOT NULL REFERENCES users(id),
                               title VARCHAR(255) NOT NULL,
                               message TEXT NOT NULL,
                               is_read BOOLEAN DEFAULT FALSE,
                               created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP

);

-- ########## 5. Traffic Violations Table ##########
CREATE TABLE traffic_violations (
                                    id BIGSERIAL PRIMARY KEY,
                                    citizen_national_id VARCHAR(14) NOT NULL,
                                    vehicle_plate_number VARCHAR(50) NOT NULL,
                                    violation_type VARCHAR(255) NOT NULL,
                                    location VARCHAR(255),
                                    amount NUMERIC(10, 2) NOT NULL,
                                    status VARCHAR(50) DEFAULT 'UNPAID', -- 'UNPAID', 'PAID'
                                    violation_date TIMESTAMP WITH TIME ZONE NOT NULL,
                                    description TEXT
);

-- ########## Insert Sample Violations Data ##########
-- Make sure the national_id exists in your users table
INSERT INTO traffic_violations (citizen_national_id, vehicle_plate_number, violation_type, location, amount, status, violation_date, description) VALUES
                                                                                                                                                      ('12345678901234', 'ABC-123', 'Exceeding Speed Limit', 'Ring Road, Cairo', 500.00, 'UNPAID', '2024-08-15 10:30:00', 'Speed was 120 km/h in a 90 km/h zone.'),
                                                                                                                                                      ('12345678901234', 'ABC-123', 'Parking Violation', 'Tahrir Square, Cairo', 150.00, 'PAID', '2024-07-20 15:00:00', 'Parked in a no-parking area.'),
                                                                                                                                                      ('12345678901234', 'XYZ-789', 'Running a Red Light', '6th of October Bridge', 1000.00, 'UNPAID', '2024-08-20 08:45:00', 'Crossed the intersection while the light was red.');


-- ########## 4. Auditing/Soft-Delete (جدول للمحذوفين) ##########

-- جدول المستخدمين المحذوفين مؤقتًا
CREATE TABLE deleted_users (
                               id BIGSERIAL PRIMARY KEY,
                               original_user_id BIGINT NOT NULL,
                               national_id VARCHAR(14),
                               full_name VARCHAR(100),
                               email VARCHAR(100),
                               deleted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);


INSERT INTO roles (name) VALUES
                             ('CITIZEN'),
                             ('EMPLOYEE'),
                             ('MANAGER');

INSERT INTO departments (name) VALUES
                                   ('Traffic Department'),
                                   ('Local Municipality');
