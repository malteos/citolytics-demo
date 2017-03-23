
# Enable debugging
error_reporting( -1 );
ini_set( 'display_errors', 1 );
$wgDebugToolbar = true;
$wgShowDebug = true;
$wgDevelopmentWarnings = true;
$wgShowExceptionDetails = true;

require_once( "$IP/extensions/Elastica/Elastica.php" );
require_once( "$IP/extensions/CirrusSearch/CirrusSearch.php" );

$wgDisableSearchUpdate = true;
$wgCirrusSearchServers = array( 'localhost' );
$wgSearchType = 'CirrusSearch';

# Enable Citolytics
$wgCirrusSearchEnableCitolytics = true;
