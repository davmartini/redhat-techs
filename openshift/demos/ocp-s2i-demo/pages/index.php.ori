<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="description" content="A simple docker helloworld example.">
        <meta name="author" content="Karthik Gaekwad">
        <meta name="viewport" content="width=device-width, initial-scale=1">
    
        <!-- Latest compiled and minified CSS -->
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
    <script type="text/javascript">
    function init ( )
    {
      timeDisplay = document.createTextNode ( "" );
      document.getElementById("clock").appendChild ( timeDisplay );
    }
    
    function updateVisit ()
    {
      visitDisplay = document.createTextNode ( "" );
      document.getElementById("visits").appendChild(visitDisplay);
    
      var counter = Cookies.get('counter');
      if (counter==null){
      console.log(counter);
          counter = 1;
      }else{
          counter = Number(counter) + 1;
      }
      Cookies.set('counter', counter);
      document.getElementById("visits").firstChild.nodeValue = counter;
    }
    
    function updateClock ()
    {
      var currentTime = new Date ( );
    
      var currentHours = currentTime.getHours ( );
      var currentMinutes = currentTime.getMinutes ( );
      var currentSeconds = currentTime.getSeconds ( );
    
      // Pad the minutes and seconds with leading zeros, if required
      currentMinutes = ( currentMinutes < 10 ? "0" : "" ) + currentMinutes;
      currentSeconds = ( currentSeconds < 10 ? "0" : "" ) + currentSeconds;
    
      // Choose either "AM" or "PM" as appropriate
      var timeOfDay = ( currentHours < 12 ) ? "AM" : "PM";
    
      // Convert the hours component to 12-hour format if needed
      currentHours = ( currentHours > 12 ) ? currentHours - 12 : currentHours;
    
      // Convert an hours component of "0" to "12"
      currentHours = ( currentHours == 0 ) ? 12 : currentHours;
    
      // Compose the string for display
      var currentTimeString = currentHours + ":" + currentMinutes + ":" + currentSeconds + " " + timeOfDay;
    
      // Update the time display
      document.getElementById("clock").firstChild.nodeValue = currentTimeString;
    }
    </script>
    </head>
    <body  onload="updateVisit(); updateClock(); setInterval('updateClock()', 1000 )">
        <!-- Fixed navbar -->
        <nav class="navbar navbar-inverse navbar-fixed-top">
          <div class="container">
            <div class="navbar-header">
              <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
              </button>
              <a class="navbar-brand" href="#">OpenShift s2i</a>
            </div>
            <div id="navbar" class="navbar-collapse collapse">
              <ul class="nav navbar-nav">
                <li class="active"><a href="#">Home</a></li>
                <li><a href="https://github.com/davmartini/redhat-techs/tree/main/openshift/demos/ocp-s2i-demo/">About</a></li>
                <li><a href="https://linkedin.com/in/davmartini">Contact</a></li>
              </ul>
            </div><!--/.nav-collapse -->
          </div>
        </nav>
    
        <div class="container theme-showcase" role="main">
    
          <!-- Main jumbotron for a primary marketing message or call to action -->
          <div class="jumbotron" style="text-align:center">
            <h2>Bienvenue à la session OpenShift 360°</h2>
            <p>OpenShift est plus qu'une plateforme de containers, c'est une plateforme cloud-native complète permettant le développement applicatif jusqu'à la mise en production d'environnements critiques</p>
            <h3><?php echo "Container ID : ".gethostname(); ?></h3>
          </div>
          <div style="text-align:center">
            <img src="images/tdsynnex.png" width="887" height="131"/>
          </div>
          <div style="background-color:blue;color:white;text-align:center">
            <p>Colombes</p>
          </div>
          <hr/>
          <div class="footer">
            <p>2022 David Martini</p>
          </div>  
</html>
