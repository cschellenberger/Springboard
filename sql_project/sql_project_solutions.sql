/* https://sql.springboard.com/
Username: student
Password: learn_sql@springboard */

/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT name AS Facility, guestcost AS Cost
FROM Facilities
WHERE guestcost > 0

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(membercost) AS no_member_cost
FROM Facilities
WHERE membercost = 0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid AS facility_id, 
       name AS facility_name, 
       membercost AS member_cost,
       monthlymaintenance AS monthly_maintenance
FROM Facilities
WHERE membercost < 0.2 * monthlymaintenance AND
      membercost > 0

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid IN (1, 5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT name AS Facility, 
       monthlymaintenance AS 'Monthly Maintenance',
       CASE WHEN monthlymaintenance <= 100 THEN 'cheap'
            ELSE 'expensive'
            END AS 'Cost Description'
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname,
       surname
 FROM Members
WHERE joindate = (SELECT MAX(joindate) FROM Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT f.name AS facility,
       CONCAT(m.firstname, ' ', m.surname) AS name
FROM Bookings b
    JOIN Facilities f
      ON f.facid = b.facid
    JOIN Members m 
      ON m.memid = b.memid
WHERE f.facid IN (0,1)
GROUP BY 1,2
ORDER BY 2

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name AS facility,
       CONCAT(m.firstname, ' ', m.surname) AS name,
       CASE WHEN b.memid = '0' THEN (b.slots * f.guestcost)
            ELSE (b.slots * f.membercost) END AS cost
FROM Bookings b
    JOIN Facilities f
      ON f.facid = b.facid
    JOIN Members m 
      ON m.memid = b.memid
WHERE b.starttime LIKE '2012-09-14%'
  AND ((m.memid =0 AND b.slots * f.guestcost > 30)
	OR (m.memid !=0 AND b.slots * f.membercost > 30))
ORDER BY 3 DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT member, facility, cost
FROM (

SELECT CONCAT(m.surname, ', ', m.firstname) AS member, 
       f.name AS facility, 
       CASE WHEN m.memid =0 THEN b.slots * f.guestcost
            ELSE b.slots * f.membercost
            END AS cost
      FROM `Members` m
      JOIN `Bookings` b 
        ON m.memid = b.memid
INNER JOIN `Facilities` f 
        ON b.facid = f.facid
WHERE b.starttime LIKE '2012-09-14%') AS bookings
	
WHERE cost > 30
ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT f.name AS facility,
       SUM(CASE WHEN b.memid = '0' THEN (b.slots * f.guestcost)
            ELSE (b.slots * f.membercost) END) AS revenue
FROM Bookings b
    JOIN Facilities f
      ON f.facid = b.facid
GROUP BY 1
HAVING revenue < 1000
ORDER BY 2 DESC