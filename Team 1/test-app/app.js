const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// PostgreSQL connection configuration
const pool = new Pool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'num1-database',
  user: process.env.DB_USER || 'num1-user',
  password: process.env.DB_PASSWORD || 'Abc@12345678',
  ssl: process.env.DB_SSL_MODE === 'disable' 
    ? false 
    : { rejectUnauthorized: false}
});

app.get('/', (req, res) => {
  res.json({
    message: 'PostgreSQL Test App',
    status: 'running',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', async (req, res) => {
  try {
    // Test database connection
    const client = await pool.connect();
    const result = await client.query('SELECT NOW()');
    client.release();

    res.json({
      status: 'healthy',
      database: 'connected',
      timestamp: result.rows[0].now,
      connection: {
        host: process.env.DB_HOST || '127.0.0.1',
        database: process.env.DB_NAME || 'num1-database'
      }
    });
  } catch (error) {
    console.error('Database connection error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message,
      connection: {
        host: process.env.DB_HOST || '127.0.0.1',
        database: process.env.DB_NAME || 'num1-database'
      }
    });
  }
});

app.get('/test-query', async (req, res) => {
  try {
    const client = await pool.connect();

    // Create a test table if it doesn't exist
    await client.query(`
      CREATE TABLE IF NOT EXISTS test_table (
        id SERIAL PRIMARY KEY,
        message TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Insert a test record
    const insertResult = await client.query(
      'INSERT INTO test_table (message) VALUES ($1) RETURNING *',
      [`Test from ${new Date().toISOString()}`]
    );

    // Query all records
    const selectResult = await client.query('SELECT * FROM test_table ORDER BY created_at DESC LIMIT 5');

    client.release();

    res.json({
      status: 'success',
      inserted: insertResult.rows[0],
      recent_records: selectResult.rows
    });
  } catch (error) {
    console.error('Query error:', error);
    res.status(500).json({
      status: 'error',
      message: error.message
    });
  }
});

app.listen(port, () => {
  console.log(`PostgreSQL test app listening on port ${port}`);
  console.log('Environment variables:');
  console.log('- DB_HOST:', process.env.DB_HOST || '127.0.0.1');
  console.log('- DB_PORT:', process.env.DB_PORT || '5432');
  console.log('- DB_NAME:', process.env.DB_NAME || 'num1-database');
  console.log('- DB_USER:', process.env.DB_USER || 'num1-user');
});