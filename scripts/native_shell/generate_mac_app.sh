LOCAL_DIR=$(cd `dirname $0`; pwd)
PROJECT_DIR=$LOCAL_DIR/..
app_path="target"
mkdir $app_path
rm -rf "$app_path/移动到这"
ln -s -f /Applications "$app_path/移动到这"
$LOCAL_DIR/gen_release_app.sh
tar -zcvf ./AdbTool_macOS.tar  -C $app_path/ "ADB TOOL.app/" "移动到这"
rm -rf "$app_path/移动到这"