# OSGB36 to WGS84 Coordinate Transformation

This M script converts coordinates from the OSGB36 (Ordnance Survey Great Britain 1936) system to the WGS84 (World Geodetic System 1984) system. It is designed for use in Power BI's Power Query Editor, making it easy to transform geospatial data from one coordinate system to another.

## How to Use

### In Power BI:
1. Open **Power Query Editor** in Power BI.
2. Create a new **Blank Query** by navigating to: `Home` > `New Source` > `Blank Query`.
3. Open the query's **Advanced Editor** for the new query.
4. Delete the existing code and paste this script.
5. In your desired table, add a new column using **Invoke Custom Function**:
    - Go to `Add Column` > `Invoke Custom Function`.
    - Set the parameters for the Easting (E) and Northing (N) columns.
6. Expand the resulting column to view the **Latitude** and **Longitude** in WGS84.

## Parameters

- **E**: Easting coordinate in OSGB36.
- **N**: Northing coordinate in OSGB36.

## Example Usage

For a table containing `Easting` and `Northing` columns, you can apply this script to get the corresponding `Latitude` and `Longitude` in WGS84 format:

| Easting | Northing | Latitude  | Longitude  |
|---------|----------|-----------|------------|
| 400000  | 100000   | 52.657570 | 1.717921   |

## Handling Null Values

The script includes a condition to handle null values for the `Easting` and `Northing` parameters. If either value is null, the script will return `null` for both `Latitude` and `Longitude` to avoid processing errors.

## Contributions

- The handling of `null` values in the script was added by Martin Fox.

## License

This script is licensed under the MIT License. You are free to use, modify, and distribute this script, provided that you include attribution. See the [LICENSE](../LICENSE) file for more details.

## Attribution

This script was adapted from a Python version authored by Dr. Hannah Fry, which was based on the mathematical process developed by Ordnance Survey. For more information, see the official Ordnance Survey documentation: [Guide to Coordinate Systems in Great Britain](https://www.ordnancesurvey.co.uk/documents/resources/guide-coordinate-systems-great-britain.pdf).

