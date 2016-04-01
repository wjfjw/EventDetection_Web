<%@page import="edu.wiki.main.*"%>
<%@page import="java.io.*,java.nio.file.Paths,java.sql.*,java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>

<head>
	<meta http-equiv="Content-Type" content="text/html" charset="UTF-8">
	<title>热点事件检测系统</title>

	<link href="./css/bootstrap-datetimepicker.css" rel="stylesheet">
	<link href="./css/bootstrap.min.css" rel="stylesheet" type="text/css" media="screen">
	<link rel="stylesheet" href="css/loading.css" media="screen" type="text/css" />
	<link rel="stylesheet" href="css/homepage.css" media="screen" type="text/css" />
	<script src="./js/jquery-2.1.4.min.js"></script>
	<script src="./js/moment-with-locales.js"></script>
	<script src="./js/bootstrap.min.js" type="text/javascript"></script>
	<script src="./js/bootstrap-datetimepicker.js"></script>
	
	<script src="http://www.google.com/jsapi"></script>
    <script src="./js/chartkick.js"></script>
    <!-- <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script> -->
    <!-- <script src="./js/jsapi.js"></script> -->
</head>

<%!
	private static final String inputFile = "../webapps/EventDetection/Result/result";
%>

<body>

	<nav class="navbar navbar-inverse navbar-fixed-top">
      <div class="container">
        <div class="navbar-header">
          <a class="navbar-brand" href="#">热点事件检测系统</a>
        </div>
      </div>
    </nav>

	<div class="jumbotron">
      <div class="container">
      	<br/><br/>
        <h1>热点事件检测</h1>
        <p>我们利用精确语义分析（ESA）技术对与中国相关的新闻标题文本进行分词、语义解释和聚类，挖掘出每天的主题事件，并分析事件的发展趋势。</p>
      </div>
    </div>
    
    <div class="container">

	<form name="pretreatment" action="pretreat.jsp" method="post">
	<div class="form-group" style="margin-left:-15px;">
		<label for="trueName" class="col-md-2 control-label" style="margin-top:5px;">事件检测开始时间：</label>
		<div class="input-group" id="datetimepicker1" style="width:40%">
			<input class="form-control required" name="startTime" id="start-time" value="" type="text" />
            <span class="input-group-addon">
				<span class="glyphicon glyphicon-calendar"></span>
            </span>
		</div>
		<script type="text/javascript">
			$(function () {
				$('#datetimepicker1').datetimepicker({format: 'YYYY-MM-DD'})
			});
		</script>
	</div>

	<div class="form-group"  style="margin-left:-15px;">
		<label for="trueName" class="col-md-2 control-label" style="margin-top:5px;">事件检测结束时间：</label>
		<div class="input-group" id="datetimepicker2" style="width:40%">
			<input class="form-control required" name="endTime" id="end-time" value="" type="text" />
            <span class="input-group-addon">
				<span class="glyphicon glyphicon-calendar"></span>
            </span>
		</div>
		<script type="text/javascript">
			$(function () {
				$('#datetimepicker2').datetimepicker({format: 'YYYY-MM-DD'})
			});
		</script>
	</div>
	
	<br/>

	<div class="row">
		<div class="col-md-2">
			<label>数据预处理:</label>
		</div>
		<div class="col-md-1">
			<input class="btn btn-success" type="submit" value="开始" onclick="showLoading()" /> 
		</div>
		<div class="col-md-2">
			<div id="caseMarron">
  				<div id="boule"></div>
  				<div id="load">
  					<p>loading……</p>
  				</div>
			</div>
		</div>
	</div>
	</form>
	
	<br/>
	
	<form name="detection" action="detect.jsp" method="post">
		<div class="row">
			<div class="col-md-2">
				<label>事件检测:</label>
			</div>
			<div class="col-md-2">
				<input class="btn btn-success" type="submit" value="开始" /> 
			</div>
		</div>
	</form>
	
	<br/><br/>
	
	<div class="row">
			<label class="col-md-2">事件发展趋势图:</label>
		</div>
		<div class="row">
    		<div class="col-md-12" id="chart-4" style="height: 300px;"></div>
    		
    		<%
    			if(request.getParameter("showResult")!=null)
				{
    				ArrayList<Event> eventList = (ArrayList<Event>)application.getAttribute("eventList");
    				out.print("<script>");
    				out.print("new Chartkick.LineChart(\"chart-4\", [");
    				for(int i=0 ; i<eventList.size() ; ++i)
    				{
    					if(i>=5)	break;
    					Event e = eventList.get(i);
    					
    					if(i!=0)	out.print(",");
    					out.print("{\"name\":\"event"+ (i+1) +"\",\"data\":{");
    					for(int j=0 ; j<e.getLastDays() ; ++j)
    					{
    						DateTime dateTime = e.getOccurrenceDate(j);
    						if(j!=0)	out.print(",");
    						String month = String.valueOf(dateTime.month);
    						String day = String.valueOf(dateTime.day);
    						if(dateTime.month < 10)
    							month = "0"+month;
    						if(dateTime.day < 10)
    							day = "0"+day;
    						out.print("\""+dateTime.year+"-"+month+"-"+day+ " 00:00:00 -0000"+ "\":" + (e.getEffect(j)*100));
    					}
    					out.print("}}");
    				}
    				out.print("] , {\"xtitle\": \"Time\", \"ytitle\": \"Effect Proportion（%）\"} );");
    				out.print("</script>");
				}
    		%>
    	</div>
		
		<br/><br/><br/><br/>
		
		<div class="row">
			<div class="col-md-2">
				<label>事件检测结果:</label>
			</div>
		</div>
		<br/>
		<div class="row">
			<div class="col-md-8  col-md-offset-2">
				<textarea rows="15" cols="80" readonly="readonly">
				<%
					if(request.getParameter("showResult")!=null)
					{
						Scanner input = new Scanner(Paths.get(inputFile));
						out.println();
						while(input.hasNextLine())
						{
							out.println(input.nextLine());
						}
						input.close();
					}
				%>
				</textarea>
			</div>	
		</div>
		
	</div>
	
	<div class="foot">Copyright © 2016 华南师范大学 吴杰锋 All Rights Reserved</div>
	
</body>

 <script>
function showLoading()
{
	document.getElementById('caseMarron').style.visibility = "visible";
}
</script>

</html>