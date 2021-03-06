# EPGD Variable Descriptions

For original variable descriptions see
[ASOS Network](https://mesonet.agron.iastate.edu/request/download.phtml?network=NY_ASOS).
Some variables were renamed and converted to Système international d'unités, SI.

| Variable   | Description                             |
| :--------- | :-------------------------------------- |
| station    | Three or four character site identifier |
| time       | Timestamp of the observation |
| temp       | Air Temperature in Celsius, typically @ 2 meters |
| dewp       | Dew Point Temperature in Celsius, typically @ 2 meters |
| humid      | Relative Humidity in % |
| wind_dir   | Wind Direction in degrees from north |
| wind_speed | Wind Speed in km/h |
| wind_gust  | Wind Gust in km/h |
| precip     | One hour precipitation for the period from the observation time to the time of the previous hourly precipitation reset. This varies slightly by site. Values are in inches. This value may or may not contain frozen precipitation melted by some device on the sensor or estimated by some other means. Unfortunately, we do not know of an authoritative database denoting which station has which sensor. |
| pressure   | Sea Level Pressure in millibar (missing in EPGD data)|
| visib      | Visibility in kilometers |

Plus extra convenience variables: year, month, day, hour, minute, time_hour.

Create ActiveRecord migration and create empty _epgd15s_ table

```sh
rails generate migration CreateEpgd15s \
  station:string time:datetime:index \
  temp:float dewp:float humid:float wind_dir:float \
  wind_speed:float wind_gust:float precip:float pressure:float visib:float \
  year:integer month:integer day:integer hour:integer minute:integer \
  time_hour:datetime:index
rails db:migrate
```

Check the _epgd15s_ schema on the _sqlite3_ console:

```sh
sqlite3 db/development.sqlite3
sqlite> .schema --indent epgd15s
```
```sql
.schema --indent epgd15s
CREATE TABLE "epgd15s"(
  "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  "station" varchar,
  "time" datetime,
  "temp" float,
  "dewp" float,
  "humid" float,
  "wind_dir" float,
  "wind_speed" float,
  "wind_gust" float,
  "precip" float,
  "pressure" float, -- missing in EPGD data
  "visib" float,
  "year" integer,
  "month" integer,
  "day" integer,
  "hour" integer,
  "minute" integer,
  "time_hour" datetime
);
```

## Importing data into SQLite3

Native datatypes, _activerecord-5.0.0.1/lib/active_record/connection_adapters/sqlite3_adapter.rb_:

```ruby
NATIVE_DATABASE_TYPES = {
   primary_key:  'INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL',
   string:       { name: "varchar" },
   text:         { name: "text" },
   integer:      { name: "integer" },
   float:        { name: "float" },
   decimal:      { name: "decimal" },
   datetime:     { name: "datetime" },
   time:         { name: "time" },
   date:         { name: "date" },
   binary:       { name: "blob" },
   boolean:      { name: "boolean" }
 }
```

**Unfortunately the import below does not work!**
```sql
.separator ','
.import db/weather_epgd_2015.csv epgd15s
-- ...
-- db/weather_epgd_2015.csv:8715: INSERT failed: datatype mismatch
```

But this works (needs _csvkit_ package; install with _pip_).
```sh
gunzip -c weather_epgd_2015.csv.gz \
  | csvsql  --no-create --insert --tables epgd15s --db sqlite:///development.sqlite3
```


## Import with ActiveRecord

Check the version of the latest migration:
```sh
rails db:version
rails db:rollback STEP=1 # if necessary
```

Define _Epgd15_ model.
```ruby
class Epgd15 < ActiveRecord::Base
end
```

Check Ruby schema in _db/schema.rb_:
```ruby
create_table "epgd15s", force: :cascade do |t|
  t.string   "station"
  t.datetime "time"
  t.float    "temp"
  t.float    "dewp"
  t.float    "humid"
  t.float    "wind_dir"
  t.float    "wind_speed"
  t.float    "wind_gust"
  t.float    "precip"
  t.float    "pressure"
  t.float    "visib"
  t.integer  "year"
  t.integer  "month"
  t.integer  "day"
  t.integer  "hour"
  t.integer  "minute"
  t.datetime "time_hour"
  t.index ["time"], name: "index_epgd15s_on_time"
  t.index ["time_hour"], name: "index_epgd15s_on_time_hour"
end
```

Now, run these commands on the Rails console
(we use the _mass_insert_ gem).

```ruby
# require 'cvs' # not necessary if on the Rails console
Zlib::GzipReader.open("db/weather_epgd_2015.csv.gz") do |gz|
  csv = CSV.new(gz, :headers => true, :header_converters => :symbol, :converters => :all)
  csv.each_slice(256) do |slice|
    ah = slice.map do |elem|
      elem.delete(:id)
      elem.to_hash
    end
    Epgd15.mass_insert ah
  end
end
Epgd15.count # should be equal 8714

Epgd15.in_batches(of: 2000) do |relation|
  ap relation.first
end
```

See also [ActiveRecord::Batches](http://api.rubyonrails.org/classes/ActiveRecord/Batches.html).


### If something goes awry...

Then try to run these commands.

```ruby
# read everything into table
all = CSV.read(open("db/weather_epgd_2015.csv"),
    :headers => true, :header_converters => :symbol, :converters => :all)

# try inserting only one record into the _epgd15s_ table
w1 = all[1].to_hash
Epgd15.create w1
Epgd15.first
ap Epgd15.first

# remove inserted record(s)
Epgd15.first.destroy
Epgd15.count # should be 0
Epgd15.destroy_all # very slow
Epgd15.in_batches(of: 1000).delete_all # quick
```

```ruby
csv = CSV.new(open("db/weather_epgd_2015.csv"),
    :headers => true, :header_converters => :symbol, :converters => :all)
csv.each_slice(2000) do |slice|
  slice[0].delete(:id)
  ap slice[0].to_hash
end
```
