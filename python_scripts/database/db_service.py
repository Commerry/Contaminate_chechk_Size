"""
Database Service
Handles SQL Server connections and data insertion
"""

from datetime import datetime
import pyodbc

class DatabaseService:
    """SQL Server database service"""
    
    def __init__(self, config):
        """Initialize database service"""
        self.config = config
        self.connection = None
    
    def connect(self):
        """Connect to SQL Server"""
        try:
            conn_str = self.config.get_connection_string()
            if not conn_str:
                return False, "Database connection string not configured"
            
            self.connection = pyodbc.connect(conn_str, timeout=5)
            return True, "Connected successfully"
        except Exception as e:
            self.connection = None
            return False, f"Connection failed: {str(e)}"
    
    def disconnect(self):
        """Disconnect from database"""
        try:
            if self.connection:
                self.connection.close()
                self.connection = None
        except:
            pass
    
    def test_connection(self):
        """Test database connection"""
        try:
            success, message = self.connect()
            if success:
                # Try a simple query
                cursor = self.connection.cursor()
                cursor.execute("SELECT 1")
                cursor.close()
                self.disconnect()
                return True, "Connection test successful"
            return False, message
        except Exception as e:
            self.disconnect()
            return False, f"Connection test failed: {str(e)}"
    
    def insert_measurement(self, data):
        """
        Insert measurement data into database
        
        Args:
            data (dict): Measurement data with keys:
                - lot: str
                - product_type: str
                - obj: str (object name)
                - size: float (mm)
        
        Returns:
            tuple: (success, message)
        """
        try:
            # Connect if not connected
            if not self.connection:
                success, message = self.connect()
                if not success:
                    return False, message
            
            # Prepare data
            table_name = self.config.get('table', 'tbl_testchecksize')
            current_time = datetime.now()
            
            # Insert query matching database structure
            query = f"""
                INSERT INTO {table_name} (datetime, lot, product_type, obj, size)
                VALUES (?, ?, ?, ?, ?)
            """
            
            values = (
                current_time,
                data.get('lot', ''),
                data.get('product_type', ''),
                data.get('obj', ''),
                data.get('size', 0.0)
            )
            
            # Execute query
            cursor = self.connection.cursor()
            cursor.execute(query, values)
            self.connection.commit()
            cursor.close()
            
            return True, f"Data saved successfully (ID: {current_time.strftime('%Y%m%d_%H%M%S')})"
        
        except Exception as e:
            try:
                if self.connection:
                    self.connection.rollback()
            except:
                pass
            return False, f"Failed to save data: {str(e)}"
    
    def get_machines(self):
        """
        Get all machines from database
        
        Returns:
            tuple: (success, data/message)
                data is a list of dicts with keys: id, name, description, status, location
        """
        try:
            # Connect if not connected
            if not self.connection:
                success, message = self.connect()
                if not success:
                    return False, message
            
            # Query machines table
            query = """
                SELECT id, name, description, status, location, created_at
                FROM tbl_machines
                ORDER BY name
            """
            
            cursor = self.connection.cursor()
            cursor.execute(query)
            
            # Fetch all rows
            machines = []
            for row in cursor.fetchall():
                machines.append({
                    'id': row.id,
                    'name': row.name,
                    'description': row.description or '',
                    'status': row.status or 'active',
                    'location': row.location or '',
                    'created_at': row.created_at.strftime('%Y-%m-%d %H:%M:%S') if row.created_at else None
                })
            
            cursor.close()
            return True, machines
        
        except Exception as e:
            return False, f"Failed to get machines: {str(e)}"
    
    def add_machine(self, machine_data):
        """
        Add a new machine to database
        
        Args:
            machine_data (dict): Machine data with keys:
                - id: str (machine ID, e.g., 'MC-01')
                - name: str
                - description: str (optional)
                - status: str (optional, default 'active')
                - location: str (optional)
        
        Returns:
            tuple: (success, message)
        """
        try:
            # Connect if not connected
            if not self.connection:
                success, message = self.connect()
                if not success:
                    return False, message
            
            # Prepare data
            current_time = datetime.now()
            
            query = """
                INSERT INTO tbl_machines (id, name, description, status, location, created_at)
                VALUES (?, ?, ?, ?, ?, ?)
            """
            
            values = (
                machine_data.get('id', ''),
                machine_data.get('name', ''),
                machine_data.get('description', ''),
                machine_data.get('status', 'active'),
                machine_data.get('location', ''),
                current_time
            )
            
            cursor = self.connection.cursor()
            cursor.execute(query, values)
            self.connection.commit()
            cursor.close()
            
            return True, f"Machine '{machine_data.get('name')}' added successfully"
        
        except Exception as e:
            try:
                if self.connection:
                    self.connection.rollback()
            except:
                pass
            return False, f"Failed to add machine: {str(e)}"
    
    def update_machine(self, machine_id, machine_data):
        """
        Update machine information
        
        Args:
            machine_id (str): Machine ID
            machine_data (dict): Updated data (name, description, status, location)
        
        Returns:
            tuple: (success, message)
        """
        try:
            # Connect if not connected
            if not self.connection:
                success, message = self.connect()
                if not success:
                    return False, message
            
            # Build update query dynamically
            fields = []
            values = []
            
            if 'name' in machine_data:
                fields.append('name = ?')
                values.append(machine_data['name'])
            
            if 'description' in machine_data:
                fields.append('description = ?')
                values.append(machine_data['description'])
            
            if 'status' in machine_data:
                fields.append('status = ?')
                values.append(machine_data['status'])
            
            if 'location' in machine_data:
                fields.append('location = ?')
                values.append(machine_data['location'])
            
            if not fields:
                return False, "No fields to update"
            
            fields.append('updated_at = ?')
            values.append(datetime.now())
            values.append(machine_id)
            
            query = f"""
                UPDATE tbl_machines
                SET {', '.join(fields)}
                WHERE id = ?
            """
            
            cursor = self.connection.cursor()
            cursor.execute(query, values)
            self.connection.commit()
            
            if cursor.rowcount == 0:
                cursor.close()
                return False, f"Machine '{machine_id}' not found"
            
            cursor.close()
            return True, f"Machine '{machine_id}' updated successfully"
        
        except Exception as e:
            try:
                if self.connection:
                    self.connection.rollback()
            except:
                pass
            return False, f"Failed to update machine: {str(e)}"
    
    def delete_machine(self, machine_id):
        """
        Delete a machine from database
        
        Args:
            machine_id (str): Machine ID
        
        Returns:
            tuple: (success, message)
        """
        try:
            # Connect if not connected
            if not self.connection:
                success, message = self.connect()
                if not success:
                    return False, message
            
            query = "DELETE FROM tbl_machines WHERE id = ?"
            
            cursor = self.connection.cursor()
            cursor.execute(query, (machine_id,))
            self.connection.commit()
            
            if cursor.rowcount == 0:
                cursor.close()
                return False, f"Machine '{machine_id}' not found"
            
            cursor.close()
            return True, f"Machine '{machine_id}' deleted successfully"
        
        except Exception as e:
            try:
                if self.connection:
                    self.connection.rollback()
            except:
                pass
            return False, f"Failed to delete machine: {str(e)}"
    
    def __enter__(self):
        """Context manager entry"""
        self.connect()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit"""
        self.disconnect()
