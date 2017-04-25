# Add this to the end of your LocalSettings.php
require_once( "$IP/extensions/Elastica/Elastica.php" );
require_once( "$IP/extensions/CirrusSearch/CirrusSearch.php" );
$wgCirrusSearchServers = array( 'localhost' );
$wgSearchType = 'CirrusSearch';
$wgCirrusSearchEnableCitolytics = true;
$wgCirrusSearchDevelOptions['ignore_missing_rev'] = true;
