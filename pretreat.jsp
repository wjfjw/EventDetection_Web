<%@page import="edu.wiki.main.*, edu.wiki.api.concept.*, edu.wiki.search.ESASearcher, edu.wiki.util.ConnectDB"%>
<%@page import="java.io.*,java.nio.file.Paths,java.sql.*,java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
<meta http-equiv="Content-Type" content="text/html" charset="UTF-8">
<title>pretreatment</title>
</head>

<%!
	private static final String inputPath = "../webapps/EventDetection/Data/";
	private static ArrayList<NewsDate> dateList;
	private static final int titleToConceptNum = 5;
	
	private static Connection conn;
	private static Statement stmtQuery;
	private static ESASearcher searcher;
%>

<%!
/**
 * 得出新闻标题对应的语义概念
 * @param title
 * @return 是否能成功将新闻标题转化为语义概念
 * @throws SQLException 
 * @throws IOException 
 */
private static boolean titleToConcept(Title title) throws IOException, SQLException
{
	IConceptVector cvBase = searcher.getConceptVector(title.content);
	IConceptVector cv = searcher.getNormalVector(cvBase,titleToConceptNum);

	if(cv == null)
		return false;
	
	IConceptIterator it = cv.orderedIterator();
	
	for(int i=0 ; i<titleToConceptNum && it.next() ; ++i)
	{
		String query = "SELECT title FROM article WHERE id=" + it.getId();
		ResultSet res = stmtQuery.executeQuery(query);
		res.next();
		String name = res.getString(1);
		title.addConcept( new Concept(it.getId(), it.getValue(), name) );
	}
	return true;
}
%>

<body>

	<%
		dateList = new ArrayList<NewsDate>();
		conn = ConnectDB.initDB();
		stmtQuery = conn.createStatement();
		searcher = new ESASearcher();
	
		String startTime = request.getParameter("startTime");
		String endTime = request.getParameter("endTime");
		
		//检查输入时间
		
		int startyear = Integer.parseInt( startTime.substring(0, 4) );
		int startmonth = Integer.parseInt( startTime.substring(5, 7) );
		int startday = Integer.parseInt( startTime.substring(8, 10) );
		
		int endyear = Integer.parseInt( endTime.substring(0, 4) );
		int endmonth = Integer.parseInt( endTime.substring(5, 7) );
		int endday = Integer.parseInt( endTime.substring(8, 10) );
		
		while( startyear <= endyear )
		{
			Scanner input = new Scanner(Paths.get(inputPath + startyear));
			while( input.hasNextInt() )
			{
				//读取每一天的日期和新闻标题
				int year = input.nextInt();
				int month = input.nextInt();
				int day = input.nextInt();
				int titleNum = input.nextInt();
				input.nextLine(); 		//读入'\n'
				//判断当前日期是否大于等于开始日期，并且小于等于结束日期
				if((month<startmonth) || (month==startmonth && day<startday))
				{
					for(int i=0 ; i<titleNum ; ++i)
						input.nextLine();
				}
				else if((year<endyear) || (year==endyear && month<endmonth) || (year==endyear && month==endmonth && day<=endday))
				{
					NewsDate date = new NewsDate(year, month, day);
					for(int i=0 ; i<titleNum ; ++i)
					{
						Title title = new Title( input.nextLine() );
						if( titleToConcept(title) )
							date.addTitle(title);
					}
					dateList.add(date);
				}
				else
					break;
			}
			input.close();
			++startyear;
		}
		conn.close();
		
		application.setAttribute("dateList", dateList);

	%>
	
	<jsp:forward page="index.jsp" />
	
</body>

</html>