# ST_InternalCenter
PostGIS Function which calculate internal-center point of a polygon.

The SRID of the polygon must be 4326.

## How to use

To install this function, run the following command on a PostgreSQL database with PostGIS installed.

$ psql -f st_internalcenter.sql

The installed functions are used in SQL as follows.

```
SELECT ST_AsText(ST_InternalCenter(g))
FROM  ST_GeomFromText('POLYGON((0 2, -1 1,0 0, 1 0, -0.5 1, 1 2, 0 2))', 4326)  AS g ;
                  st_astext
---------------------------------------------
 POINT(-0.312820512820513 1.385897435897436)
(1 row)
```

## How to calculate the center point

- Basically, the centroid is used. (using ST_Centroid)

- If the centroid is not inside the polygon,
  cut the polygon with a straight line connecting
  the centroid and the nearest point on the polygon
  and use the center point of the intersection.

- When the line does not intersect the polygon
  (due to calculation errors), a buffer with a radius of
  1-meter is generated around the point on the polygon
  closest to the centroid, and use the centroid of
  the intersection of the buffer and the polygon.

## Author

- Takeshi Sagara <sagara@info-proto.com>

## License

The MIT License.
