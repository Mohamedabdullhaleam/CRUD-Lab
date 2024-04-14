<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Some Aggregates</title>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <style>
        .infoText {
            font-size: 20px;
            font-weight: bold;
            color: #34495e;
            margin-top: 10px;
        }
    </style>
    <script type="text/javascript">
        google.charts.load('current', {'packages':['corechart']});
        google.charts.setOnLoadCallback(drawChart);

        function drawChart() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Country');
            data.addColumn('number', 'Percentage');

            <% 
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                int countMohamed = 0;
                int countZagazig = 0;
                StringBuilder languageData = new StringBuilder(); // Moved outside the try block
                try {
                    String url = "jdbc:mysql://localhost:3306/mycvproject?useSSL=false";
                    String user = "root";
                    String password = "Mohamedlimo236";
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(url, user, password);

                    String query = "SELECT country, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM person) AS percentage FROM person GROUP BY country";
                    pstmt = conn.prepareStatement(query);
                    rs = pstmt.executeQuery();

                    while(rs.next()) {
                        out.println("data.addRow(['" + rs.getString("country").replaceAll("'", "\\\\'") + "', " + rs.getDouble("percentage") + "]);");
                    }

                    // Fetch count of people named Mohamed
                    String mohamedQuery = "SELECT COUNT(*) as countMohamed FROM person WHERE fname LIKE 'Mohamed%'";
                    pstmt = conn.prepareStatement(mohamedQuery);
                    rs = pstmt.executeQuery();
                    if (rs.next()) {
                        countMohamed = rs.getInt("countMohamed");
                    }

                    // Fetch count of people from Zagazig
                    String zagazigQuery = "SELECT COUNT(*) as countZagazig FROM person WHERE city = 'Zagazig'";
                    pstmt = conn.prepareStatement(zagazigQuery);
                    rs = pstmt.executeQuery();
                    if (rs.next()) {
                        countZagazig = rs.getInt("countZagazig");
                    }

                    // fetch language counts
                    String languageQuery = "SELECT languageName, COUNT(*) AS count FROM language GROUP BY languageName";
                    pstmt = conn.prepareStatement(languageQuery);
                    rs = pstmt.executeQuery();

                    while (rs.next()) {
                        languageData.append("<p class='infoText'>")
                                    .append(rs.getString("languageName"))
                                    .append(": ")
                                    .append(rs.getInt("count"))
                                    .append("</p>");
                    }

                } catch(Exception e) {
                    out.println("/* Exception: " + e.toString() + " */");
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) { out.println("/* RS Close Error: " + e.getMessage() + " */"); }
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { out.println("/* Stmt Close Error: " + e.getMessage() + " */"); }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { out.println("/* Conn Close Error: " + e.getMessage() + " */"); }
                }
            %>

            var options = {
                title: 'Percentage of Nationalities',
                is3D: true,
                width: 600,
                height: 450
            };

            var chart = new google.visualization.PieChart(document.getElementById('piechart'));
            chart.draw(data, options);
        }
    </script>
</head>
<body>
    <h1>Nationality Statistics</h1>
    <div id="piechart"></div>
    <h1>First Name Mohamed</h1>
    <p id="mohamedCount" class="infoText">Number of people named Mohamed: <%=countMohamed%></p>
    <h1>People from Zagazig</h1>
    <p id="zagazigCount" class="infoText">Number of people from Zagazig: <%=countZagazig%></p>
    <h1>Programming Languages </h1>
    <%=languageData.toString()%> <!-- Display the language data -->
</body>
</html>
