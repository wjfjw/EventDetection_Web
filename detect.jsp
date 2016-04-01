<%@page import="edu.wiki.main.*"%>
<%@page import="java.io.*,java.nio.file.Paths,java.sql.*,java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html" charset="UTF-8">
<title>Detection</title>
</head>
<body>

<%!
	private static ArrayList<Event> eventList;
	private static final int minPts = 5;
	private static final double eps = 0.5;
	private static final double topicSimParam = 0.6;
	private static final int titleToConceptNum = 5;
	private static final String outputFile = "../webapps/EventDetection/Result/result";
%>

<%!
	private void output(ArrayList<NewsDate> dateList) throws FileNotFoundException
	{
		PrintWriter out = new PrintWriter(outputFile);	//result,testResult
		int n = eventList.size();
	
		//按照事件发生的天数从长到短排序
		eventList.sort(new Comparator<Event>() {
			public int compare(Event o1, Event o2) {
				return o2.getLastDays() - o1.getLastDays();
			}
		});
		for(int i=0 ; i<n ; ++i)
		{
			Event e = eventList.get(i);
		
			out.printf("Event %d :\n" , i+1);
			out.println("Dates:");
			for(int j=0 ; j<e.getLastDays() ; ++j)
			{
				DateTime dateTime = e.getOccurrenceDate(j);
				if(e.getEffect(j) > 0)
				{
					out.printf("%d.%d.%d ", dateTime.year , dateTime.month, dateTime.day);
					out.printf("%.3f\t", e.getEffect(j));
				}
			}
			out.printf("\nLast for %d Days\n" , e.getLastDays());
			out.println("Concepts:");
			for(int j=0 ; j<e.getConceptList().size() ; ++j)
			{
				if(j>0)
					out.print(", ");
				out.print(e.getConceptList().get(j).name);
				out.printf("(%d)" , e.getConceptNum(j));
			}
	//		for(Concept c : e.getConceptList())
	//		{
	//			out.print(c.name + ", ");
	//		}
		
			out.print("\nRelated newsTitles:");
			for(int j=0 ; j<e.getLastDays() ; ++j)
			{
				if(e.getEffect(j) > 0)
				{
					DateTime dateTime = e.getOccurrenceDate(j);
					out.printf("\n%d %d %d\t", dateTime.year, dateTime.month, dateTime.day);
					out.printf("%.3f\n", e.getEffect(j));
					for(Title t : e.getTitleList(j))
					{
						out.println(t.content);
					}
				}
			}
			out.println();
		}
		out.close();
	}
%>

<%
	eventList = new ArrayList<Event>();
    ArrayList<NewsDate> dateList = (ArrayList<NewsDate>)application.getAttribute("dateList");
	for(NewsDate date : dateList)
	{
		DBSCAN dbscan  = new DBSCAN( minPts, eps, date.getTitleList(), titleToConceptNum );
		dbscan.calSimilarity();
		dbscan.work();
		date.createTopicList();
	}
	DetectEvent.detectAllEvents(dateList, eventList, topicSimParam, titleToConceptNum);
	output(dateList);
	
	application.setAttribute("eventList", eventList);
%>

	<jsp:forward page="index.jsp">
		<jsp:param name="showResult" value="true" />
	</jsp:forward>

</body>
</html>