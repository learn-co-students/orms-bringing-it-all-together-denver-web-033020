require_relative '../config/environment'
require 'pp'
class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql =  <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY,
          name TEXT,
          breed TEXT
          )
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs;"
        DB[:conn].execute(sql)
    end

    def save
        if @id
            self.update
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id = ?
        SQL
        new_dog = DB[:conn].execute(sql, id).flatten
        Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?
            LIMIT 1
        SQL
        dog = DB[:conn].execute(sql, name, breed).flatten
        if !dog.empty?
            found_dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
        else
            new_dog = Dog.create(name: name, breed: breed)
        end
    end
    
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL
        new_dog = DB[:conn].execute(sql, name).flatten
        Dog.new(id: new_dog[0], name: new_dog[1], breed: new_dog[2])
    end

    def update
        sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
    SQL
    DB[:conn].execute(sql, @name, @breed, @id)
    end
end