# EPGD Variable Descriptions

see [ASOS Network](https://mesonet.agron.iastate.edu/request/download.phtml?network=NY_ASOS)

TODO: import data to SQLite

| Variable  | Description                             |
| :-------- | :-------------------------------------- |
| station   | Three or four character site identifier |
| valid     | Timestamp of the observation |
| tmpf      | Air Temperature in Celsius, typically @ 2 meters |
| dwpf      | Dew Point Temperature in Celsius, typically @ 2 meters |
| relh      | Relative Humidity in % |
| drct      | Wind Direction in degrees from north |
| sknt      | Wind Speed in km/h |
| p01i      | One hour precipitation for the period from the observation time to the time of the previous hourly precipitation reset.
This varies slightly by site. Values are in inches.
This value may or may not contain frozen precipitation melted
by some device on the sensor or estimated by some other means.
Unfortunately, we do not know of an authoritative database |
|           | denoting which station has which sensor. |
| alti      | Pressure altimeter in inches |
| mslp      | Sea Level Pressure in millibar |
| vsby      | Visibility in kilometers |
| gust      | Wind Gust in km/h |
| skyc1     | Sky Level 1 Coverage |
| skyc2     | Sky Level 2 Coverage |
| skyc3     | Sky Level 3 Coverage |
| skyc4     | Sky Level 4 Coverage |
| skyl1     | Sky Level 1 Altitude in feet |
| skyl2     | Sky Level 2 Altitude in feet |
| skyl3     | Sky Level 3 Altitude in feet |
| skyl4     | Sky Level 4 Altitude in feet |
| presentwx | Present Weather Codes (space seperated) |
| metar     | unprocessed reported observation in METAR format |
