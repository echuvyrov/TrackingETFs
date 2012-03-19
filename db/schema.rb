# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120315013939) do

  create_table "etf_prices", :force => true do |t|
    t.date     "pricedate"
    t.decimal  "price"
    t.integer  "fund_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "etf_types", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "etftype_name"
  end

  create_table "funds", :force => true do |t|
    t.string   "tickersymbol"
    t.string   "etfname"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "etftype"
    t.string   "etforganization_type"
    t.string   "etfsubtype"
    t.text     "tax_consequences"
  end

  create_table "funds_trackable_items", :id => false, :force => true do |t|
    t.integer  "fund_id"
    t.integer  "trackable_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lookups", :force => true do |t|
    t.string   "code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_types", :force => true do |t|
    t.string "etforganization_type"
  end

  create_table "trackable_items", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
