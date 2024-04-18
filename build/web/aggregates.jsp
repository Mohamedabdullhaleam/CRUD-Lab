<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Some Aggregates</title>
    <link rel="icon" type="image/png" href="resume.png">
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <style>
    body {
        font-family: 'Arial', sans-serif; /* Ensures consistent font across the page */
        margin: 0;
        padding: 0;
        display: flex;
        flex-direction: column;
        align-items: center; /* Centers all child content horizontally */
    }
    .infoText {
        font-size: 20px;
        font-weight: bold;
        color: #34495e;
        margin-top: 10px;
    }
    .infoTable {
    width: 70%; /* Full width */
    border-collapse: collapse; /* Ensures borders between cells are merged */
    box-shadow: 0 2px 15px rgba(0,0,0,0.1); /* Subtle shadow around the table */
    background-color: #ffffff; /* White background for the cells */
    margin: 20px 0; /* Add some space around the table */
    font-size: 16px; /* Increase font size for readability */
    text-align: left; /* Align text to the left in each cell */
    }

    .infoTable th, .infoTable td {
        border: 1px solid #ddd; /* Light grey border */
        padding: 12px 15px; /* Spacing inside each cell */
        text-align: center; /* Centering text for headers and cells */
    }

    .infoTable th {
        background-color: #3498db; /* Darker background for the header */
        color: #ffffff; /* White text color */
        font-weight: bold; /* Make header text bold */
    }

    .infoTable tr:nth-child(even) {
        background-color: #f2f2f2; /* Zebra striping for rows */
    }

    .infoTable tr:hover {
        background-color: #dfe6e9; /* Light blue background on row hover */
        cursor: pointer; /* Changes cursor to a pointer to indicate interactivity */
    }

    /* Responsive adjustments for smaller screens */
    @media screen and (max-width: 600px) {
        .infoTable {
            font-size: 14px; /* Smaller font size on small devices */
        }
    }

    h1 {
        font-size: 28px; /* Larger font size */
        font-weight: bold; /* Bold text */
        color: #3498db; /* A blue color */
        background-color: #ecf0f1; /* Light gray background */
        padding: 10px 20px; /* Padding around text */
        border-radius: 5px; /* Rounded corners */
        box-shadow: 0 2px 5px rgba(0,0,0,0.1); /* Subtle shadow */
        text-shadow: 1px 1px 2px rgba(0,0,0,0.15); /* Text shadow for depth */
        margin-top: 30px; /* More space on top */
        margin-bottom: 20px; /* Space below */
        width: 80%; /* Control the width */
        text-align: center; /* Ensure text is centered */
    }
</style>

    <script type="text/javascript">
       // to draw charts
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
                // 
                StringBuilder languageData = new StringBuilder(); 
                StringBuilder projectData = new StringBuilder();
                StringBuilder hobbyData = new StringBuilder();
                StringBuilder courseData = new StringBuilder();
                StringBuilder enrollmentData = new StringBuilder();
                StringBuilder zagPeopleData = new StringBuilder();
                
                try {
                    String url = "jdbc:mysql://localhost:3306/mycvproject?useSSL=false";
                    String user = "root";
                    String password = "Mohamedlimo236";
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(url, user, password);
                    
                    // chart query
                    String chartQuery = "SELECT country, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM person) AS percentage FROM person GROUP BY country";
                    pstmt = conn.prepareStatement(chartQuery);
                    rs = pstmt.executeQuery();

                    while(rs.next()) {
                        out.println("data.addRow(['" + rs.getString("country").replaceAll("'", "\\\\'") + "', " + rs.getDouble("percentage") + "]);");
                    }


                    // fetch language counts
                   String languageQuery = "SELECT languageName, COUNT(*) AS count " +
                                "FROM mycvproject.language " + 
                                "WHERE languageName IS NOT NULL AND languageName <> '' " +
                                "GROUP BY languageName " +
                                "ORDER BY count DESC; ";
                    pstmt = conn.prepareStatement(languageQuery);
                    rs = pstmt.executeQuery();

                    // Start building the HTML table
                    languageData.append("<table class='infoTable'>");
                    languageData.append("<tr><th>Language Name</th><th>Count</th></tr>");  // Table header

                    while (rs.next()) {
                        languageData.append("<tr>")
                                    .append("<td>").append(rs.getString("languageName")).append("</td>")
                                    .append("<td>").append(rs.getInt("count")).append("</td>")
                                    .append("</tr>");
                    }
                    languageData.append("</table>");

                    // most common projects in egypt
                    String projectQuery = "SELECT projectName as most_common_project_in_Egypt, COUNT(*) as count " +
                        "FROM mycvproject.project " +
                        "JOIN mycvproject.person ON person.idperson = project.person_idperson " +
                        "WHERE country = 'Egypt' AND projectName IS NOT NULL AND TRIM(projectName) <> '' " +
                        "GROUP BY projectName " +
                        "ORDER BY count DESC " +
                        "LIMIT 4;";
                    pstmt = conn.prepareStatement(projectQuery);
                    rs = pstmt.executeQuery();

                    // Build HTML table data
                    projectData.append("<table class='infoTable'><tr><th>Project Name</th><th>Count</th></tr>");
                    while (rs.next()) {
                        projectData.append("<tr><td>")
                                  .append(rs.getString("most_common_project_in_Egypt"))
                                  .append("</td><td>")
                                  .append(rs.getInt("count"))
                                  .append("</td></tr>");
                    }
                    projectData.append("</table>");
                    // most enrolled courses
                   String enrollmentQuery = "SELECT courseName, COUNT(idperson) AS total_enrollments " +
                                     "FROM mycvproject.course " +
                                     "JOIN mycvproject.person ON person.idperson = course.person_idperson " +
                                     "WHERE courseName IS NOT NULL AND TRIM(courseName) <> '' " +
                                     "GROUP BY courseName " +
                                     "ORDER BY total_enrollments DESC " +
                                     "LIMIT 5";
                    pstmt = conn.prepareStatement(enrollmentQuery);
                    rs = pstmt.executeQuery();

                    // Start table HTML for top enrollments
                    enrollmentData.append("<table class='infoTable'><tr><th>Course Name</th><th>Total Enrollments</th></tr>");
                    while (rs.next()) {
                        enrollmentData.append("<tr><td>")
                                      .append(rs.getString("courseName"))
                                      .append("</td><td>")
                                      .append(rs.getInt("total_enrollments"))
                                      .append("</td></tr>");
                    }
                    enrollmentData.append("</table>");
                   
                    
                    // people from eg,italy,esp studying IOT or django
                   String courseQuery = "SELECT COUNT(idperson) AS count, courseName " +
                                "FROM mycvproject.person " +
                                "JOIN mycvproject.course ON person.idperson = course.person_idperson " +
                                "WHERE country IN ('Egypt', 'Spain', 'Italy') AND courseName IN ('IoT', 'Django') " +
                                "GROUP BY courseName " +
                                "ORDER BY count DESC";
                    pstmt = conn.prepareStatement(courseQuery);
                    rs = pstmt.executeQuery();

                    courseData.append("<table class='infoTable'><tr><th>Course Name</th><th>Count</th></tr>");
                    while (rs.next()) {
                        courseData.append("<tr><td>")
                                  .append(rs.getString("courseName"))
                                  .append("</td><td>")
                                  .append(rs.getInt("count"))
                                  .append("</td></tr>");
                    }
                    courseData.append("</table>");

                    
                    // Least common hobbies 
                   String query = "SELECT hobbyName AS least_common_hobby, COUNT(*) AS count " +
                           "FROM mycvproject.hobby " +
                           "WHERE hobbyName IS NOT NULL AND TRIM(hobbyName) <> '' " +
                           "GROUP BY hobbyName " +
                           "HAVING COUNT(*) >= 1 " +
                           "ORDER BY count ASC " +
                           "LIMIT 3;";
                    pstmt = conn.prepareStatement(query);
                    rs = pstmt.executeQuery();

                    // Start building the HTML table
                    hobbyData.append("<table class='infoTable'>");
                    hobbyData.append("<tr><th>Hobby Name</th><th>Count</th></tr>");

                    while (rs.next()) {
                        hobbyData.append("<tr>")
                                 .append("<td>").append(rs.getString("least_common_hobby")).append("</td>")
                                 .append("<td>").append(rs.getInt("count")).append("</td>")
                                 .append("</tr>");
                    }
                    hobbyData.append("</table>");

                    // Fetch count of people from Zagazig
                   String peopleQuery = "SELECT fName, COUNT(*) OVER() AS totalCount FROM mycvproject.person WHERE city = 'Zagazig'";
                    pstmt = conn.prepareStatement(peopleQuery);
                    rs = pstmt.executeQuery();

                    // Start building the HTML table
                    zagPeopleData.append("<table class='infoTable'><tr><th>First Name</th></tr>");
                    int totalCount = 0; 
                    while (rs.next()) {
                        totalCount++ ;
                        // Append each row of data to the table
                       zagPeopleData.append("<tr><td>")
                                   .append(rs.getString("fName"))
                                   .append("</td>");       
                    }
                    // Append the final row with the total count
                    zagPeopleData.append("<tr><td colspan='1' style='text-align: center;'><strong>Total People from Zagazig:   ")
                                 .append(totalCount)
                                 .append("</strong></td></tr>");
                    zagPeopleData.append("</table>");
                    
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
    <h1>Programming Languages </h1>
    <%=languageData.toString()%> 
    <h1>Top Projects in Egypt</h1>
    <%=projectData.toString()%> 
    <h1>Top 5 Enrolled Courses</h1>
    <%=enrollmentData.toString()%> 
    <h1>People from Egypt or italy studying IOT or Django</h1>
    <%=courseData.toString()%> 
    <h1>Least Common hobbies</h1>
    <%=hobbyData.toString()%> <!-- Display the project data -->
    <h1>People from Zagazig</h1>
    <%=zagPeopleData.toString()%>
    
</body>

</html>
