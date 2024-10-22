/*
This function converts OSGB36 (Ordnance Survey Great Britain) easting and northing coordinates to WGS84 latitude and longitude.
*/

let
    OSGB36toWGS84 = (optional E as number, optional N as number) as record =>
    if E = null or N = null then
        let
        in
            [Latitude = null, Longitude = null]
    else
        let
            // Constants for the transformation
            a = 6377563.396,
            b = 6356256.909,
            F0 = 0.9996012717,
            lat0 = 49 * Number.PI / 180,
            lon0 = -2 * Number.PI / 180,
            N0 = -100000,
            E0 = 400000,
            e2 = 1 - (b * b) / (a * a),
            n = (a - b) / (a + b),

            // Function to calculate the meridional arc
            meridionalArc = (lat, lat0) =>
            let
                M1 = (1 + n + (5 / 4) * Number.Power(n, 2) + (5 / 4) * Number.Power(n, 3)) * (lat - lat0),
                M2 = (3 * n + 3 * Number.Power(n, 2) + (21 / 8) * Number.Power(n, 3)) * Number.Sin(lat - lat0) * Number.Cos(lat + lat0),
                M3 = ((15 / 8) * Number.Power(n, 2) + (15 / 8) * Number.Power(n, 3)) * Number.Sin(2 * (lat - lat0)) * Number.Cos(2 * (lat + lat0)),
                M4 = (35 / 24) * Number.Power(n, 3) * Number.Sin(3 * (lat - lat0)) * Number.Cos(3 * (lat + lat0)),
                M = b * F0 * (M1 - M2 + M3 - M4)
            in
                M,

            // Initial values
            lat = lat0,
            M = 0.0,

            // Iteratively calculate latitude
            iterateLatitude = (N, N0, M, lat, a, F0) =>
            let
                latNew = (N - N0 - M) / (a * F0) + lat,
                MNew = meridionalArc(latNew, lat0)
            in
                if Number.Abs(N - N0 - MNew) < 0.00001 then
                    latNew
                else
                    @iterateLatitude(N, N0, MNew, latNew, a, F0),

            // Calculate latitude and meridional arc
            latFinal = iterateLatitude(N, N0, M, lat, a, F0),
            MFinal = meridionalArc(latFinal, lat0),

            // Transverse radius of curvature
            nu = a * F0 / Number.Sqrt(1 - e2 * Number.Power(Number.Sin(latFinal), 2)),

            // Meridional radius of curvature
            rho = a * F0 * (1 - e2) * Number.Power(1 - e2 * Number.Power(Number.Sin(latFinal), 2), -1.5),
            eta2 = nu / rho - 1,

            // Calculate additional parameters
            VII = Number.Tan(latFinal) / (2 * rho * nu),
            VIII = Number.Tan(latFinal) / (24 * rho * Number.Power(nu, 3)) * (5 + 3 * Number.Power(Number.Tan(latFinal), 2) + eta2 - 9 * Number.Power(Number.Tan(latFinal), 2) * eta2),
            IX = Number.Tan(latFinal) / (720 * rho * Number.Power(nu, 5)) * (61 + 90 * Number.Power(Number.Tan(latFinal), 2) + 45 * Number.Power(Number.Tan(latFinal), 4)),
            X = 1 / Number.Cos(latFinal) / nu,
            XI = 1 / Number.Cos(latFinal) / (6 * Number.Power(nu, 3)) * (nu / rho + 2 * Number.Power(Number.Tan(latFinal), 2)),
            XII = 1 / Number.Cos(latFinal) / (120 * Number.Power(nu, 5)) * (5 + 28 * Number.Power(Number.Tan(latFinal), 2) + 24 * Number.Power(Number.Tan(latFinal), 4)),
            XIIA = 1 / Number.Cos(latFinal) / (5040 * Number.Power(nu, 7)) * (61 + 662 * Number.Power(Number.Tan(latFinal), 2) + 1320 * Number.Power(Number.Tan(latFinal), 4) + 720 * Number.Power(Number.Tan(latFinal), 6)),
            dE = E - E0,

            // Calculate latitude and longitude in Airy 1830
            latAiry = latFinal - VII * Number.Power(dE, 2) + VIII * Number.Power(dE, 4) - IX * Number.Power(dE, 6),
            lonAiry = lon0 + X * dE - XI * Number.Power(dE, 3) + XII * Number.Power(dE, 5) - XIIA * Number.Power(dE, 7),

            // Convert to degrees
            latDeg = latAiry * 180 / Number.PI,
            lonDeg = lonAiry * 180 / Number.PI,

            // Helmert Transformation constants
            tx = 446.448,
            ty = -125.157,
            tz = 542.060,
            s = -20.4894 * Number.Power(10,(-6)),
            rx = 0.1502 / 3600 * Number.PI / 180,
            ry = 0.2470 / 3600 * Number.PI / 180,
            rz = 0.8421 / 3600 * Number.PI / 180,

            // Convert to Cartesian coordinates
            H = 0, // Assume orthometric height
            x1 = (nu / F0 + H) * Number.Cos(latAiry) * Number.Cos(lonAiry),
            y1 = (nu / F0 + H) * Number.Cos(latAiry) * Number.Sin(lonAiry),
            z1 = ((1 - e2) * nu / F0 + H) * Number.Sin(latAiry),

            // Apply Helmert Transformation
            x2 = tx + (1 + s) * x1 + (-rz) * y1 + (ry) * z1,
            y2 = ty + (rz) * x1 + (1 + s) * y1 + (-rx) * z1,
            z2 = tz + (-ry) * x1 + (rx) * y1 + (1 + s) * z1,

            // Convert back to spherical coordinates
            a2 = 6378137.0, // WGS84 semi-major axis
            b2 = 6356752.3142, // WGS84 semi-minor axis
            e22 = 1 - (b2 * b2) / (a2 * a2),
            p = Number.Sqrt(x2 * x2 + y2 * y2),

            latWGS84Iter = (latWGS84, p, e22, z2) =>
            let
                nu2 = a2 / Number.Sqrt(1 - e22 * Number.Power(Number.Sin(latWGS84), 2)),
                latNew = Number.Atan2(z2 + e22 * nu2 * Number.Sin(latWGS84), p)
            in
                if Number.Abs(latWGS84 - latNew) < 0.000000000000001 then
                    latNew
                else
                    @latWGS84Iter(latNew, p, e22, z2),

            latWGS84 = latWGS84Iter(latAiry, p, e22, z2),
            lonWGS84 = Number.Atan2(y2, x2),

            // Convert back to degrees
            latWGS84Deg = latWGS84 * 180 / Number.PI,
            lonWGS84Deg = lonWGS84 * 180 / Number.PI
        in
            [Latitude = latWGS84Deg, Longitude = lonWGS84Deg]
in
    OSGB36toWGS84
