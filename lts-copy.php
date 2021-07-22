<?php //phpinfo(); exit();?>
<?php //shell_exec('bash ' . getcwd() . '/lts.sh > ' . getcwd() . '/lts-output.txt'); ?>

<html>
	<head>
		<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
		<script>
			$(document).ready(function() {
				if(confirm('Are you sure you want to copy live to sandbox? This cannot be undone once started.')) {
					/*$.ajax({
						url: 'lts-php.php',
						method: 'GET',
						async: true,
						success: function(data) {

						},
						error: function(a, b, c) {
							$("body").prepend(c);
						}
					});*/
				}
				else {
					$("body").prepend("<h1>Nothing to do. <a href='./'>Return To Site</a>")
				}
			});

			var interval = setInterval(reloadOutput, 1000);
			var xmlhttp = new XMLHttpRequest();

            function reloadOutput() {
                xmlhttp.open("GET", "lts-output.txt", false);
				xmlhttp.send(null);
                
                $("#output").html(xmlhttp.responseText);

				if($("#output").html().indexOf("has been updated.") >= 0) {
					clearInterval(interval);
					console.log("Finished");
				}

				window.scrollTo(0, document.body.scrollHeight);
				console.log("Refresh");
            }
		</script>
	</head>

	<body>
		<div id="output"></div>
	</body>
</html>
