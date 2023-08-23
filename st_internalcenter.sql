DROP FUNCTION IF EXISTS ST_Internalcenter(geometry);

CREATE FUNCTION ST_Internalcenter(gm_in geometry)
RETURNS geometry 
AS $$
DECLARE 
    geom_type text;
    gm_polygon geometry;
    gm_center  geometry;
    gm_closest geometry;
    gm_line geometry;
    gm_intersection geometry;
    dx double precision;
    dy double precision;
BEGIN
    SELECT GeometryType(gm_in) INTO geom_type;
    IF geom_type = 'MULTIPOLYGON' THEN
        gm_polygon := ST_GeometryN(gm_in, 1);
    ELSIF geom_type = 'POLYGON' THEN
        gm_polygon := gm_in;
    ELSE
        RAISE EXCEPTION 'Param must be Polygon or MultiPolygon';
    END IF;
    gm_center := ST_Centroid(gm_polygon);

    IF NOT ST_Intersects(gm_center, gm_polygon) THEN
        SELECT ST_ClosestPoint(gm_polygon, gm_center) INTO gm_closest;
        -- RAISE NOTICE 'ClosestPoing: %', ST_AsGeoJSON(gm_closest);
        dx := ST_X(gm_closest) - ST_X(gm_center);
        dy := ST_Y(gm_closest) - ST_Y(gm_center);
        SELECT ST_MakeLine(
            gm_center,
            ST_SetSRID(ST_Point(
                ST_X(gm_center) + 10.0 * dx, ST_Y(gm_center) + 10.0 * dy
                ), 4326)
            ) INTO gm_line;
        -- RAISE NOTICE 'line:%', ST_AsGeoJSON(gm_line);
        SELECT ST_Intersection(ST_Buffer(gm_polygon, 0), gm_line) INTO gm_intersection;
        -- RAISE NOTICE 'intersection(line): %', ST_AsGeoJSON(gm_intersection);
        IF ST_NPoints(gm_intersection) = 0
            OR ST_Length(ST_GeometryN(gm_intersection, 1)::geography) < 1.0e-3 THEN
            gm_intersection := ST_Intersection(
                ST_Buffer(gm_closest::geography, 1.0)::geometry,
                gm_polygon
            );
            -- RAISE NOTICE 'intersection(polygon): %', ST_AsGeoJSON(gm_intersection);
        END IF;
        gm_center := ST_Centroid(ST_GeometryN(gm_intersection, 1));
    END IF;
    RETURN gm_center;
END; 
$$ LANGUAGE plpgsql VOLATILE;
