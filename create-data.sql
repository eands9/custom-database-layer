-- Create cats table
CREATE TABLE IF NOT EXISTS cats (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    breed VARCHAR(100),
    age INTEGER,
    color VARCHAR(50),
    weight_kg DECIMAL(4,2),
    is_indoor BOOLEAN DEFAULT true,
    adoption_date DATE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample cat data
INSERT INTO cats (name, breed, age, color, weight_kg, is_indoor, adoption_date, description) VALUES
('Whiskers', 'Maine Coon', 3, 'Orange Tabby', 6.5, true, '2022-03-15', 'A fluffy and friendly cat who loves to play with yarn'),
('Shadow', 'British Shorthair', 5, 'Gray', 4.8, true, '2021-07-22', 'Calm and dignified, enjoys quiet afternoons by the window'),
('Luna', 'Siamese', 2, 'Cream and Brown', 3.2, true, '2023-01-10', 'Very vocal and social, loves attention from humans'),
('Mittens', 'Persian', 4, 'White', 5.1, true, '2020-11-08', 'Long-haired beauty with a gentle temperament'),
('Tiger', 'Bengal', 1, 'Golden Spotted', 3.8, false, '2024-02-14', 'Energetic and playful, enjoys outdoor adventures'),
('Smokey', 'Russian Blue', 6, 'Blue-Gray', 4.2, true, '2019-05-30', 'Shy but affectionate once trust is established'),
('Patches', 'Calico', 3, 'Multicolored', 4.0, true, '2022-09-12', 'Playful tortoiseshell with a mischievous personality'),
('Oliver', 'Ragdoll', 4, 'Blue Point', 7.2, true, '2021-12-03', 'Large and docile, goes limp when picked up'),
('Cleo', 'Egyptian Mau', 2, 'Silver Spotted', 3.5, true, '2023-06-18', 'Athletic and intelligent, loves to climb tall furniture'),
('Ginger', 'Scottish Fold', 5, 'Orange', 4.7, true, '2020-08-25', 'Sweet-natured with distinctive folded ears'),
('Midnight', 'Bombay', 3, 'Black', 4.1, true, '2022-04-07', 'Sleek black coat, very affectionate and vocal'),
('Snowball', 'Turkish Angora', 2, 'Pure White', 3.9, true, '2023-10-11', 'Elegant and graceful with stunning blue eyes'),
('Rusty', 'Abyssinian', 1, 'Ruddy Brown', 3.3, false, '2024-01-20', 'Active and curious, loves exploring the garden'),
('Princess', 'Himalayan', 6, 'Seal Point', 5.8, true, '2019-03-14', 'Regal and calm, enjoys being pampered and groomed'),
('Bandit', 'American Shorthair', 4, 'Brown Tabby', 5.5, false, '2021-10-09', 'Adventurous outdoor cat with distinctive mask-like markings');

-- Create an index on name for faster searches
CREATE INDEX idx_cats_name ON cats(name);

-- Create an index on breed for filtering
CREATE INDEX idx_cats_breed ON cats(breed);
