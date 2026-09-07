import Quickshell
import QtQuick


Item {
   id: powerService

   function poweroff(): void {
      Quickshell.execDetached(["systemctl", "poweroff"])
   }

   function reboot(): void {
      Quickshell.execDetached(["systemctl", "reboot"])
   }

   function sleep(): void {
      Quickshell.execDetached(["systemctl", "suspend"])
   }

   function hiberante(): void {
      Quickshell.execDetached(["systemctl", "hibernate"])
   }
}
