require 'pry'
class Dog

    attr_accessor :id, :name, :breed

    def initialize (hash)
        hash.each do |key, value|
            self.send("#{key}=",value)
        end
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed BREED
            )        
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", self.name, self.breed)[0][0]
        self
    end

    def self.create(hash)
        dog = self.new(hash)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = self.new(id: row[0], name: row[1], breed: row[2])
        dog
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        row = DB[:conn].execute(sql, id).first
        self.new_from_db(row)
    end

    def self.find_or_create_by(hash)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed]).first
        if row != nil
            self.new_from_db(row)
        else
            self.create(hash)
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        row = DB[:conn].execute(sql, name).first
        self.new_from_db(row)
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
        dog = DB[:conn].execute("SELECT * FROM dogs")
    end
end