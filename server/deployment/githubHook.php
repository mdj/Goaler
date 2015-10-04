<?
// Remember to add /var/www/.ssh/rsa.pub

if ( $_POST['payload'] ) {
    echo $_POST['payload'];
    
	echo exec('git pull origin master');
}
?>


