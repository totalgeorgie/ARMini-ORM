require 'sqlite3'

ROOT_FOLDER = File.join(File.dirname(__FILE__), '../..')
ARMINI_SQL_FILE = File.join(ROOT_FOLDER, 'armini.sql')
ARMINI_DB_FILE = File.join(ROOT_FOLDER, 'armini.db')

class DBConnection
  def self.open(db_file_name)
    @db = SQLite3::Database.new(db_file_name)
    @db.results_as_hash = true
    @db.type_translation = true

    @db
  end

  def self.reset
    commands = [
      "rm #{ARMINI_DB_FILE}",
      "cat #{ARMINI_SQL_FILE} | sqlite3 #{ARMINI_DB_FILE}"
    ]

    commands.each { |command| `#{command}` }
    DBConnection.open(ARMINI_DB_FILE)
  end

  def self.instance
    reset if @db.nil?

    @db
  end

  def self.execute(*args)
    puts args[0]

    instance.execute(*args)
  end

  def self.execute2(*args)
    puts args[0]

    instance.execute2(*args)
  end

  def self.last_insert_row_id
    instance.last_insert_row_id
  end

  private

  def initialize(db_file_name)
  end
end