// restore.js
import pkg from 'pg';
const { Client } = pkg;
import fs from 'fs';

// Read the backup SQL
const sql = fs.readFileSync('edunova_backup.sql', 'utf8');

// Use the DATABASE_URL from your new Railway Postgres
const client = new Client({
  connectionString: process.env.DATABASE_URL
});

async function restore() {
  try {
    await client.connect();
    await client.query(sql);
    console.log('✅ Database restored!');
  } catch (err) {
    console.error('❌ Error:', err);
  } finally {
    await client.end();
  }
}

restore();