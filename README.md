#ARMini - minimalist Ruby ORM

A minimalist Ruby ORM (Object-relational mapper) implementing the Active Record pattern built to connect a SQLite DB to your application's PORO (Plain Old Ruby Objects).

##Usage

Have your application's model classes inherit from the SQLObject class.
With Ruby metaprogramming, ARMini will add the standard CRUD operations and attributes to this model by finding the associated table/columns from the SQLite DB.
ActiveSupport::Inflector is used for titlization of properties.

Standard SQL operations and basic relational associations are supported too, via the Searchable and Associatable modules.

##Configuration

Create a armini.db and a armini.sql file to hold your SQLite DB and sql commands to initialize it as needed.
Connection.rb holds the specific DB connection info for your particular SQLite instance.
At a future date, I hope to abstract out the specific persistence implementation.

##Testing

All RSpec tests located in /spec.

##Details

ARMini is a personal project and not production ready! Feel free to play around with it for a concise look at implementing a SQL ORM with Ruby.