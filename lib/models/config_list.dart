class ConfigList {
  String configName;
  String configIcon;
  String configRoute;

  ConfigList(this.configRoute,this.configName,this.configIcon);
  static List<ConfigList> configList = [
    ConfigList('1',"打开Memo存储路径","lib/assets/floder_icon.png"),
    ConfigList('2',"登录设备","lib/assets/equipment.png"),
    ConfigList('3',"导入Memo","lib/assets/file_download_icon.png"),
    ConfigList('4',"导出Memo","lib/assets/file_upload_icon.png"),
  ];
}