# Working EPGD weather data

We are going to implement an JSON:API endpoint for weather data from EPGD.

```ruby
#<Epgd15:0x007fb193e5b2e8>
{
            :id => 26149,
       :station => "EPGD",
          :time => Thu, 01 Jan 2015 00:30:00 UTC +00:00,
          :temp => -4.0,
          :dewp => -4.0,
         :humid => 100.0,
      :wind_dir => 290.0,
    :wind_speed => 6.69,
     :wind_gust => nil,
        :precip => 0.0,
      :pressure => nil,
         :visib => 2.49,
          :year => 2015,
         :month => 1,
           :day => 1,
          :hour => 0,
        :minute => 30,
     :time_hour => Thu, 01 Jan 2015 00:30:00 UTC +00:00
}
```

Other approaches:

1. [ServerLess Framework](https://serverless.com) – build auto-scaling, pay-per-execution,
  event-driven apps on AWS Lambda
1. [Fission](http://fission.io) – serverless functions for Kubernetes.
