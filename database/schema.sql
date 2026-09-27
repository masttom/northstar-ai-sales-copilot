-- Northstar Commercial Solutions — PostgreSQL Schema v1
-- Generated from the frozen Synthetic Data Foundation seed dataset.

BEGIN;

CREATE TABLE sales_users (
    sales_user_id VARCHAR(16) PRIMARY KEY,
    name TEXT NOT NULL,
    role VARCHAR(40) NOT NULL CHECK (role IN ('ACCOUNT_EXECUTIVE','SENIOR_ACCOUNT_EXECUTIVE','SALES_MANAGER','REGIONAL_SALES_MANAGER')),
    territory TEXT NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE'))
);

CREATE TABLE accounts (
    account_id VARCHAR(16) PRIMARY KEY,
    account_name TEXT NOT NULL UNIQUE,
    segment TEXT NOT NULL CHECK (segment IN ('Hotels & Resorts','Restaurant Groups','Café & Bakery Chains','Catering / Institutional Food Service')),
    account_tier VARCHAR(20) NOT NULL CHECK (account_tier IN ('STANDARD','PREFERRED','STRATEGIC')),
    account_status VARCHAR(20) NOT NULL CHECK (account_status IN ('ACTIVE')),
    customer_since DATE NOT NULL,
    sales_territory TEXT NOT NULL,
    account_owner_id VARCHAR(16) NOT NULL REFERENCES sales_users(sales_user_id)
);

CREATE TABLE products (
    product_id VARCHAR(16) PRIMARY KEY,
    sku VARCHAR(40) NOT NULL UNIQUE,
    product_name TEXT NOT NULL UNIQUE,
    brand TEXT NOT NULL,
    category TEXT NOT NULL,
    product_family VARCHAR(30) NOT NULL,
    product_role VARCHAR(30) NOT NULL CHECK (product_role IN ('ACCESSORY','CONSUMABLE','CORE_EQUIPMENT','SERVICE_PRODUCT','SUPPORTING_EQUIPMENT')),
    lifecycle_status VARCHAR(20) NOT NULL CHECK (lifecycle_status IN ('ACTIVE','PHASE_OUT','DISCONTINUED')),
    commercial_status VARCHAR(20) NOT NULL CHECK (commercial_status IN ('NORMAL','PROMOTIONAL','PRICE_PROTECTED','CLEARANCE')),
    list_price_idr NUMERIC(15,2) NOT NULL CHECK (list_price_idr >= 0),
    launch_date DATE NOT NULL,
    discontinued_date DATE,
    CHECK (discontinued_date IS NULL OR discontinued_date >= launch_date),
    CHECK (lifecycle_status <> 'DISCONTINUED' OR discontinued_date IS NOT NULL)
);

CREATE TABLE opportunities (
    opportunity_id VARCHAR(24) PRIMARY KEY,
    account_id VARCHAR(16) NOT NULL REFERENCES accounts(account_id),
    owner_id VARCHAR(16) NOT NULL REFERENCES sales_users(sales_user_id),
    opportunity_name TEXT NOT NULL,
    stage VARCHAR(24) NOT NULL CHECK (stage IN ('DISCOVERY','SOLUTION_DESIGN','PROPOSAL','NEGOTIATION','CLOSED_WON','CLOSED_LOST')),
    estimated_value_idr NUMERIC(15,2) NOT NULL CHECK (estimated_value_idr >= 0),
    expected_close_date DATE NOT NULL,
    target_deployment_date DATE NOT NULL,
    customer_requirements_json JSONB NOT NULL CHECK (jsonb_typeof(customer_requirements_json) = 'object'),
    current_discount_pct NUMERIC(5,2) NOT NULL CHECK (current_discount_pct BETWEEN 0 AND 100),
    requested_discount_pct NUMERIC(5,2) NOT NULL CHECK (requested_discount_pct BETWEEN 0 AND 100),
    outstanding_questions_json JSONB NOT NULL CHECK (jsonb_typeof(outstanding_questions_json) = 'array')
);

CREATE TABLE opportunity_solution_lines (
    solution_line_id VARCHAR(16) PRIMARY KEY,
    opportunity_id VARCHAR(24) NOT NULL REFERENCES opportunities(opportunity_id),
    product_id VARCHAR(16) NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    estimated_unit_price_idr NUMERIC(15,2),
    CHECK (estimated_unit_price_idr IS NULL OR estimated_unit_price_idr >= 0)
);

CREATE TABLE orders (
    order_id VARCHAR(16) PRIMARY KEY,
    account_id VARCHAR(16) NOT NULL REFERENCES accounts(account_id),
    order_date DATE NOT NULL,
    order_status VARCHAR(20) NOT NULL
);

CREATE TABLE order_lines (
    order_line_id VARCHAR(16) PRIMARY KEY,
    order_id VARCHAR(16) NOT NULL REFERENCES orders(order_id),
    product_id VARCHAR(16) NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price_idr NUMERIC(15,2) NOT NULL CHECK (unit_price_idr >= 0),
    installation_location TEXT NOT NULL
);

CREATE TABLE agreements (
    agreement_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(16) NOT NULL REFERENCES accounts(account_id),
    agreement_name TEXT NOT NULL UNIQUE,
    agreement_type VARCHAR(30) NOT NULL CHECK (agreement_type IN ('PREFERRED_COMMERCIAL','STRATEGIC_FRAMEWORK')),
    effective_from DATE NOT NULL,
    effective_to DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE','EXPIRED')),
    CHECK (effective_to >= effective_from)
);

CREATE TABLE commercial_entitlements (
    entitlement_id VARCHAR(16) PRIMARY KEY,
    account_id VARCHAR(16) NOT NULL REFERENCES accounts(account_id),
    agreement_id VARCHAR(20) NOT NULL REFERENCES agreements(agreement_id),
    entitlement_type VARCHAR(40) NOT NULL CHECK (entitlement_type IN ('CUSTOMER_COMMERCIAL_AGREEMENT')),
    effective_from DATE NOT NULL,
    effective_to DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('ACTIVE','EXPIRED')),
    CHECK (effective_to >= effective_from)
);

CREATE TABLE inventory_positions (
    inventory_position_id VARCHAR(16) PRIMARY KEY,
    product_id VARCHAR(16) NOT NULL REFERENCES products(product_id),
    warehouse_id VARCHAR(16) NOT NULL,
    on_hand INTEGER NOT NULL CHECK (on_hand >= 0),
    reserved INTEGER NOT NULL CHECK (reserved >= 0),
    available INTEGER NOT NULL CHECK (available >= 0),
    last_updated TIMESTAMPTZ NOT NULL,
    UNIQUE (product_id, warehouse_id),
    CHECK (reserved <= on_hand),
    CHECK (available = on_hand - reserved)
);

CREATE TABLE incoming_inventory (
    incoming_id VARCHAR(16) PRIMARY KEY,
    product_id VARCHAR(16) NOT NULL REFERENCES products(product_id),
    warehouse_id VARCHAR(16) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    expected_arrival DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('CONFIRMED','IN_TRANSIT','DELAYED'))
);

-- Indexes follow expected Copilot lookup paths. Primary keys and UNIQUE constraints
-- already create their own indexes, so they are not duplicated here.
CREATE INDEX idx_accounts_owner ON accounts(account_owner_id);
CREATE INDEX idx_opportunities_account ON opportunities(account_id);
CREATE INDEX idx_opportunities_owner ON opportunities(owner_id);
CREATE INDEX idx_solution_lines_opportunity ON opportunity_solution_lines(opportunity_id);
CREATE INDEX idx_solution_lines_product ON opportunity_solution_lines(product_id);
CREATE INDEX idx_orders_account ON orders(account_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_lines_product ON order_lines(product_id);
CREATE INDEX idx_agreements_account ON agreements(account_id);
CREATE INDEX idx_entitlements_account ON commercial_entitlements(account_id);
CREATE INDEX idx_inventory_product ON inventory_positions(product_id);
CREATE INDEX idx_incoming_product ON incoming_inventory(product_id);
CREATE INDEX idx_incoming_eta ON incoming_inventory(expected_arrival);

COMMIT;
