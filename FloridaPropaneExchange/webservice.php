<?php
	
	require_once("Rest.inc.php");
	define('URL','http://myphpdevelopers.com/dev/ocrscanner/');
	class API extends REST {
	
		public $data = "";
		
		const DB_SERVER = "localhost";
		const DB_USER = "myphpdev_ocrscan";
		const DB_PASSWORD = "myphpdev_ocrscan";
		const DB = "myphpdev_ocrscanner";
		
		private $db = NULL;
	
		public function __construct(){
			parent::__construct();				// Init parent contructor
			$this->dbConnect();					// Initiate Database connection
		}
		
		/*
		 *  Database connection 
		*/
		private function dbConnect(){
			$this->db = mysql_connect(self::DB_SERVER,self::DB_USER,self::DB_PASSWORD);
			if($this->db)
				mysql_select_db(self::DB,$this->db);
		}
		
		/*
		 * Public method for access api.
		 * This method dynmically call the method based on the query string
		 *
		 */
		public function processApi(){
			if(!isset($_REQUEST['rquest']))
			{
				$error = array('status' => "bad request", "msg" => "Invalid URL");
				$this->response($this->json($error),404);
				
			}
			
			$func = strtolower(trim(str_replace("/","",$_REQUEST['rquest'])));
			if((int)method_exists($this,$func) > 0)
				$this->$func();
			else{
				$error = array('status' => "bad request", "msg" => "Invalid URL");
				$this->response($this->json($error),404);
				
				}	
						// If the method not exist with in this class, response would be "Page not found".
		}
		
		private function AddUserData(){	
			// Cross validation if the request method is GET else it will return "Not Acceptable" status
			if($this->get_request_method() != "GET"){
				$error = array('status' => "bad request", "msg" => "Invalid Method");
				$this->response($this->json($error),406);
			}
			
			for ($i=1; $i < 500; $i++) {
				$firstname = ucfirst(strtolower($this->generateRandomString(4)));
				$lastname = ucfirst(strtolower($this->generateRandomString(4)));
				$dateOfB  = $this->GenerateDOB();
				$userPhone = $this->GeneratePhone(10);
				$email = strtolower($firstname).'.'.strtolower($lastname).'@gmail.com';
				$insertQuery = "INSERT INTO `contactlistone` SET `Firstname`='".$firstname."',`Lastname`='".$lastname."',`DateOfBirth`='".$dateOfB."',`UserPhoneNumber`='".$userPhone."',`Useremail`='".$email."'";
				//echo $insertQuery;
				mysql_query($insertQuery);
			}
		}
		
		/* List All the videos with pagination*/
		
		private function getAllUserWithPagination(){	 
			// Cross validation if the request method is GET else it will return "Not Acceptable" status
			if($this->get_request_method() != "GET"){
				$error = array('status' => "bad request", "msg" => "Invalid Method");
				$this->response($this->json($error),406);
			}
			$CurrentPage 	= $_GET['CurrentPage'];
			$dataperpage 	= $_GET['dataperpage'];
			$LowrLimit 		= $CurrentPage*$dataperpage;
			
			$sql1 = "SELECT Firstname, Lastname, DateOfBirth, UserPhoneNumber, Useremail,Gender,ID FROM `contactlistone` ORDER BY Firstname ASC limit $LowrLimit,$dataperpage";
			$sqlTotal = mysql_fetch_array(mysql_query("SELECT COUNT(ID) as `totaldata` FROM `contactlistone`",$this->db));
			$sql = mysql_query($sql1, $this->db);
			if($sqlTotal['totaldata'] > 0){
				$providerctr 	= 0;
				$result = array();
				$arrone = array();
				while($rlt = mysql_fetch_array($sql,MYSQL_ASSOC)){
						
					$arrone[$providerctr]["Firstname"] 	= $rlt['Firstname'];
					$arrone[$providerctr]["Lastname"] 	= $rlt['Lastname'];
					$arrone[$providerctr]["DateOfBirth"] 	= $rlt['DateOfBirth'];
					$arrone[$providerctr]["UserPhoneNumber"] 	= $rlt['UserPhoneNumber'];
					$arrone[$providerctr]["Useremail"] 	= $rlt['Useremail'];
					$arrone[$providerctr]["Gender"] 	= $rlt['Gender'];
					$arrone[$providerctr]["userID"] 	= $rlt['ID'];
					$providerctr++;
					
				}
				$totalpages 			= ceil($sqlTotal['totaldata']/$dataperpage);
				$result['status']		= 'success';
				$result['totaldata']    = (string)$sqlTotal['totaldata'];
				$result['totalpages']   = (string)$totalpages;
				$result['userdata']	= $arrone;
				
				// If success everythig is good send header as "OK" and return list of users in JSON format
				$this->response($this->json($result), 200);
			} else {
				
				// If no records "No Content" status
				$fail = array('status' => "fail", "msg" => "No any video detail");
				$this->response($this->json($fail),200);
				
			}
		}

		private function GetCurrentMonthBirthday()
		{
			if($this->get_request_method() != "GET"){
				$error = array('status' => "bad request", "msg" => "Invalid Method");
				$this->response($this->json($error),406);
			}
			$sql1 = "SELECT DAY(`DateOfBirth`) as dateofbirth FROM `contactlistone` WHERE MONTH(STR_TO_DATE(`DateOfBirth`, '%Y-%m-%d')) = MONTH(NOW()) GROUP BY DAY(`DateOfBirth`)";
			$sql  = mysql_query($sql1);
			if (mysql_num_rows($sql)>0) {
				
				$providerctr 	= 0;
				$result = array();
				$arrone = array();
						
				while($rlt = mysql_fetch_array($sql,MYSQL_ASSOC)){
					$arrone[$providerctr]['dateofbirth'] = $rlt['dateofbirth'];
					$providerctr++;
				}
				$result['totaldata']    = $arrone;
				$result['status']		= 'success';
				$this->response($this->json($result), 200);
			} else {
				// If no records "No Content" status
				$fail = array('status' => "success", "msg" => "Thre is no birthday this month");
				$this->response($this->json($fail),200);
			}
		}
		
		private function GetBirthdayList()
		{
			if($this->get_request_method() != "GET"){
				$error = array('status' => "bad request", "msg" => "Invalid Method");
				$this->response($this->json($error),406);
			}
			$sql1 = "SELECT DAY(`DateOfBirth`) as dateofbirth,MONTH(`DateOfBirth`) as dateofbirthmonth FROM `contactlistone` WHERE MONTH(STR_TO_DATE(`DateOfBirth`, '%Y-%m-%d')) = MONTH(NOW()) GROUP BY DAY(`DateOfBirth`)";
			$sql  = mysql_query($sql1);
			if (mysql_num_rows($sql)>0) {
				
				$providerctr 	= 0;
				$result = array();
				$arrone = array();
						
				while($rlt = mysql_fetch_array($sql,MYSQL_ASSOC)){
					$arrone[$providerctr]['dateofbirth'] = $rlt['dateofbirth'];
					$dob = (strlen($rlt['dateofbirth']) > 1)?$rlt['dateofbirth']:'0'.$rlt['dateofbirth'];
					$NewSql = "SELECT ID,Firstname, Lastname, DateOfBirth, UserPhoneNumber, Useremail,Gender FROM `contactlistone` WHERE DATE_FORMAT(`DateOfBirth`, '%m-%d')='".$rlt['dateofbirthmonth'].'-'.$dob."'";
					$NewSqlOne = mysql_query($NewSql);
					if (mysql_num_rows($NewSqlOne)>0) {
						
						$providerctra 	= 0;
						$arrtwo			= array();
						
						while($rltone = mysql_fetch_array($NewSqlOne,MYSQL_ASSOC)){
							
							$arrtwo[$providerctra]["UserId"] 			= $rltone['ID'];
							$arrtwo[$providerctra]["Firstname"] 		= $rltone['Firstname'];
							$arrtwo[$providerctra]["Lastname"] 			= $rltone['Lastname'];
							$arrtwo[$providerctra]["DateOfBirth"] 		= $rltone['DateOfBirth'];
							$arrtwo[$providerctra]["UserPhoneNumber"] 	= $rltone['UserPhoneNumber'];
							$arrtwo[$providerctra]["Useremail"] 		= $rltone['Useremail'];
							$arrtwo[$providerctra]["Gender"] 			= $rltone['Gender'];
							$providerctra++;
						}
						$arrone[$providerctr]['userlist'] = $arrtwo;
					}
					$providerctr++;
				}
				$result['totaldata']    = $arrone;
				$result['status']		= 'success';
				$this->response($this->json($result), 200);
			} else {
				// If no records "No Content" status
				$fail = array('status' => "success", "msg" => "Thre is no birthday this month");
				$this->response($this->json($fail),200);
			}	
		}

		private function GetProvidedDayBirthday()
		{
			if($this->get_request_method() != "GET"){
				$error = array('status' => "bad request", "msg" => "Invalid Method");
				$this->response($this->json($error),406);
			}
			$NewSql = "SELECT ID,Firstname, Lastname, DateOfBirth, UserPhoneNumber, Useremail,Gender FROM `contactlistone` WHERE DATE_FORMAT(`DateOfBirth`, '%m-%d')=DATE_FORMAT('".$_REQUEST['provideddate']."', '%m-%d')";
			$NewSqlOne = mysql_query($NewSql);
			if (mysql_num_rows($NewSqlOne)>0) {
				$result         = array();
				$providerctra 	= 0;
				$arrtwo			= array();
				while($rltone = mysql_fetch_array($NewSqlOne,MYSQL_ASSOC)){
					//"1990-10-26"
					//"12/17/1983"; mm/dd/yyyy
				   $birthDate = explode("-",  $rltone['DateOfBirth']);
				   $age = (date("md", date("U", mktime(0, 0, 0, $birthDate[1], $birthDate[2], $birthDate[0]))) > date("md")
				    ? ((date("Y") - $birthDate[0]))
				    : (date("Y") - $birthDate[0]));
					
					$arrtwo[$providerctra]["UserId"] 			= $rltone['ID'];
					$arrtwo[$providerctra]["Firstname"] 		= $rltone['Firstname'];
					$arrtwo[$providerctra]["Lastname"] 			= $rltone['Lastname'];
					$arrtwo[$providerctra]["DateOfBirth"] 		= date("F j, Y",strtotime($rltone['DateOfBirth']));
					$arrtwo[$providerctra]["UserPhoneNumber"] 	= $rltone['UserPhoneNumber'];
					$arrtwo[$providerctra]["Useremail"] 		= $rltone['Useremail'];
					$arrtwo[$providerctra]["Gender"] 			= $rltone['Gender'];
					$arrtwo[$providerctra]["agecalculation"] 	= "Turns " . $age ." Years today";
					$providerctra++;
				}
				$result['datastring']	= $arrtwo;
				$result['status']		= 'success';
				$this->response($this->json($result), 200);
			} else {
				// If no records "No Content" status
				$fail = array('status' => "error", "msg" => "Thre is no birthday this month");
				$this->response($this->json($fail),200);
			}		
		}
		
		private function GetCurrentDayBirthday()
		{
			if($this->get_request_method() != "GET"){
				$error = array('status' => "bad request", "msg" => "Invalid Method");
				$this->response($this->json($error),406);
			}
			$NewSql = "SELECT ID,Firstname, Lastname, DateOfBirth, UserPhoneNumber, Useremail,Gender FROM `contactlistone` WHERE DATE_FORMAT(`DateOfBirth`, '%m-%d')=DATE_FORMAT(NOW(), '%m-%d')";
			$NewSqlOne = mysql_query($NewSql);
			if (mysql_num_rows($NewSqlOne)>0) {
				$result         = array();
				$providerctra 	= 0;
				$arrtwo			= array();
				while($rltone = mysql_fetch_array($NewSqlOne,MYSQL_ASSOC)){
					$arrtwo[$providerctra]["UserId"] 			= $rltone['ID'];
					$arrtwo[$providerctra]["Firstname"] 		= $rltone['Firstname'];
					$arrtwo[$providerctra]["Lastname"] 			= $rltone['Lastname'];
					$arrtwo[$providerctra]["DateOfBirth"] 		= $rltone['DateOfBirth'];
					$arrtwo[$providerctra]["UserPhoneNumber"] 	= $rltone['UserPhoneNumber'];
					$arrtwo[$providerctra]["Useremail"] 		= $rltone['Useremail'];
					$arrtwo[$providerctra]["Gender"] 			= $rltone['Gender'];
					$providerctra++;
				}
				$result['datastring']	= $arrtwo;
				$result['status']		= 'success';
				$this->response($this->json($result), 200);
			} else {
				// If no records "No Content" status
				$fail = array('status' => "success", "msg" => "Thre is no birthday this month");
				$this->response($this->json($fail),200);
			}		
		}
		
		private function GetUpcomingBirthdayThisMonth()
		{
			
			if($this->get_request_method() != "GET"){
				$error = array('status' => "bad request", "msg" => "Invalid Method");
				$this->response($this->json($error),406);
			}
			$sql1 = "SELECT DAY(`DateOfBirth`) as dateofbirth,MONTH(`DateOfBirth`) as dateofbirthmonth FROM `contactlistone` WHERE MONTH(STR_TO_DATE(`DateOfBirth`, '%Y-%m-%d')) = MONTH(NOW()) AND DAY(`DateOfBirth`) > DAY(NOW()) GROUP BY DAY(`DateOfBirth`)";
			$sql  = mysql_query($sql1);
			if (mysql_num_rows($sql)>0) {
				
				$providerctr 	= 0;
				$result = array();
				$arrone = array();
						
				while($rlt = mysql_fetch_array($sql,MYSQL_ASSOC)){
					$arrone[$providerctr]['dateofbirth'] = $rlt['dateofbirth'];
					$dob = (strlen($rlt['dateofbirth']) > 1)?$rlt['dateofbirth']:'0'.$rlt['dateofbirth'];
					$NewSql = "SELECT ID,Firstname, Lastname, DateOfBirth, UserPhoneNumber, Useremail,Gender FROM `contactlistone` WHERE DATE_FORMAT(`DateOfBirth`, '%m-%d')='".$rlt['dateofbirthmonth'].'-'.$dob."'";
					$NewSqlOne = mysql_query($NewSql);
					if (mysql_num_rows($NewSqlOne)>0) {
						
						$providerctra 	= 0;
						$arrtwo			= array();
						
						while($rltone = mysql_fetch_array($NewSqlOne,MYSQL_ASSOC)){
							
							$arrtwo[$providerctra]["UserId"] 			= $rltone['ID'];
							$arrtwo[$providerctra]["Firstname"] 		= $rltone['Firstname'];
							$arrtwo[$providerctra]["Lastname"] 			= $rltone['Lastname'];
							$arrtwo[$providerctra]["DateOfBirth"] 		= $rltone['DateOfBirth'];
							$arrtwo[$providerctra]["UserPhoneNumber"] 	= $rltone['UserPhoneNumber'];
							$arrtwo[$providerctra]["Useremail"] 		= $rltone['Useremail'];
							$arrtwo[$providerctra]["Gender"] 			= $rltone['Gender'];
							$providerctra++;
						}
						$arrone[$providerctr]['userlist'] = $arrtwo;
					}
					$providerctr++;
				}
				$result['totaldata']    = $arrone;
				$result['status']		= 'success';
				$this->response($this->json($result), 200);
			} else {
				// If no records "No Content" status
				$fail = array('status' => "success", "msg" => "Thre is no birthday this month");
				$this->response($this->json($fail),200);
			}
			
		}
		
		private function GetCurrentMonthApponitment()
		{
			if($this->get_request_method() != "GET"){
				$error = array('status' => "bad request", "msg" => "Invalid Method");
				$this->response($this->json($error),406);
			}
			$sql1 = "SELECT DAY(`DateOfBirth`) as dateofbirth,MONTH(`DateOfBirth`) as dateofbirthmonth FROM `contactlistone` WHERE MONTH(STR_TO_DATE(`DateOfBirth`, '%Y-%m-%d')) = MONTH(NOW()) AND DAY(`DateOfBirth`) > DAY(NOW()) GROUP BY DAY(`DateOfBirth`)";
			$sql  = mysql_query($sql1);
			if (mysql_num_rows($sql)>0) {
				
				$providerctr 	= 0;
				$result = array();
				$arrone = array();
						
				while($rlt = mysql_fetch_array($sql,MYSQL_ASSOC)){
					$arrone[$providerctr]['dateofbirth'] = $rlt['dateofbirth'];
					$dob = (strlen($rlt['dateofbirth']) > 1)?$rlt['dateofbirth']:'0'.$rlt['dateofbirth'];
					$NewSql = "SELECT ID,Firstname, Lastname, DateOfBirth, UserPhoneNumber, Useremail,Gender FROM `contactlistone` WHERE DATE_FORMAT(`DateOfBirth`, '%m-%d')='".$rlt['dateofbirthmonth'].'-'.$dob."'";
					$NewSqlOne = mysql_query($NewSql);
					if (mysql_num_rows($NewSqlOne)>0) {
						
						$providerctra 	= 0;
						$arrtwo			= array();
						
						while($rltone = mysql_fetch_array($NewSqlOne,MYSQL_ASSOC)){
							
							$arrtwo[$providerctra]["UserId"] 			= $rltone['ID'];
							$arrtwo[$providerctra]["Firstname"] 		= $rltone['Firstname'];
							$arrtwo[$providerctra]["Lastname"] 			= $rltone['Lastname'];
							$arrtwo[$providerctra]["DateOfBirth"] 		= $rltone['DateOfBirth'];
							$arrtwo[$providerctra]["UserPhoneNumber"] 	= $rltone['UserPhoneNumber'];
							$arrtwo[$providerctra]["Useremail"] 		= $rltone['Useremail'];
							$arrtwo[$providerctra]["Gender"] 			= $rltone['Gender'];
							$providerctra++;
						}
						$arrone[$providerctr]['userlist'] = $arrtwo;
					}
					$providerctr++;
				}
				$result['totaldata']    = $arrone;
				$result['status']		= 'success';
				$this->response($this->json($result), 200);
			} else {
				// If no records "No Content" status
				$fail = array('status' => "success", "msg" => "Thre is no birthday this month");
				$this->response($this->json($fail),200);
			}
		}
		
		private function GetCurrentWeakApponitment()
		{
			$sql = "SELECT DAY(`Apponitmentdate`) FROM `Apponitment` WHERE MONTH(STR_TO_DATE(`Apponitmentdate`, '%Y-%m-%d')) = MONTH(NOW()) GROUP BY DAY(`Apponitmentdate`)";
		}
		
		private function GetCurrentDayApponitment()
		{
			$sql = "SELECT DAY(`Apponitmentdate`) FROM `Apponitment` WHERE MONTH(STR_TO_DATE(`Apponitmentdate`, '%Y-%m-%d')) = MONTH(NOW()) GROUP BY DAY(`Apponitmentdate`)";
		}
		
		private function GeneratePhone($length)
		{
			$characters = '0123456789';
		    $randomString = '';
		    for ($i = 0; $i < $length; $i++) {
		        $randomString .= $characters[rand(0, strlen($characters) - 1)];
		    }
		    return $randomString;
		}
		
		private function GenerateDOB()
		{
			$start = strtotime("01-10-1980");
			$end =  strtotime("31-12-1999");
			$randomDate = date("Y-m-d", rand($start, $end));
			return $randomDate;
		}
		
		/*
		 * 
		*/
		
		private function Sendmail(){
			if($this->get_request_method() != "GET"){
				$error = array('status' => "bad request", "msg" => "Invalid Method");
				$this->response($this->json($error),406);
			}
			
			$CompanyName 			= trim($_REQUEST['CompanyName']);
			$OrderBy 				= trim($_REQUEST['OrderBy']);
			$ContactPhoneOremail    = trim($_REQUEST['ContactPhoneOremail']);
			$date 					= trim($_REQUEST['date']);
			$Streetaddress			= trim($_REQUEST['Streetaddress']);
			$City				    = trim($_REQUEST['city']);
			$Numberofbbqtanks 		= trim($_REQUEST['Numberofbbqtanks']);
			$DeliveryMethod         = trim($_REQUEST['DeliveryMethod']);
			$AdminEmail 			= "joe.ewart@flapropane.com";
            //$AdminEmail 			= "santanu.adhikary@sbr-technologies.com";
			
			$to  = $AdminEmail;
			// subject
			$subject = 'Request for tank delivery from '.$OrderBy;
			
			// message
			$message = '
			<html>
			<head>
			  <title>Request for tank delivery from '.$OrderBy.'</title>
			</head>
			<body>
			  <p>These Are the details</p>
			  <table>
			    <tr>
			      <td>Company Name</td><td>'.$CompanyName.'</td>
			    </tr>
			    <tr>
			      <td>Ordered By</td><td>'.$OrderBy.'</td>
			    </tr>
			    <tr>
			      <td>Contact phone or email</td><td>'.$ContactPhoneOremail.'</td>
			    </tr>
			    <tr>
			      <td>Date</td><td>'.$date.'</td>
			    </tr>
			    <tr>
			      <td>Street Address</td><td>'.$Streetaddress.'</td>
			    </tr>
			    <tr>
			      <td>City</td><td>'.$City.'</td>
			    </tr>
			    <tr>
			      <td>Number of BBQ Tanks Required</td><td>'.$Numberofbbqtanks.'</td>
			    </tr>
			    <tr>
			      <td>Delivery Requested :</td><td>'.$DeliveryMethod.'</td>
			    </tr>
			  </table>
			</body>
			</html>
			';
			
			// To send HTML mail, the Content-type header must be set
			$headers  = 'MIME-Version: 1.0' . "\r\n";
			$headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";
			
			// Additional headers
			$headers .= 'To: '.$AdminEmail. "\r\n";
			$headers .= 'From:'.$OrderBy. "\r\n";
			
			// Mail it
			$sendmail = mail($to, $subject, $message, $headers);
			if($sendmail)
			{
				$fail = array('status' => "success", "msg" => "mail Submitted");
				$this->response($this->json($fail),200);
			} else {
				// If no records "No Content" status
				$fail = array('status' => "Error", "msg" => "There is some error, please try again later");
				$this->response($this->json($fail),200);
			}
			
		}
		
		private function generateRandomString($length) {
		    $characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
		    $randomString = '';
		    for ($i = 0; $i < $length; $i++) {
		        $randomString .= $characters[rand(0, strlen($characters) - 1)];
		    }
		    return $randomString;
		}
		
		
		/*
		 *	Encode array into JSON
		*/
		private function json($data){
			if(is_array($data)){
				return json_encode($data);
			}
		}
	}

	$api = new API;
	$api->processApi();
?>