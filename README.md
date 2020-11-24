# core-date
JS Date library for browser and server

**Doc will be added very soon**

## Convert string to milliseconds

### Supported units
-ms Milliseconds
-s	Seconds
-m	Minutes
-h	Hours
-d	Days

### Examples
```javascript
var milliseconds= DateLib.toMilliseconds(125125); // 125125
var milliseconds= DateLib.toMilliseconds('125125ms'); // 125125
var milliseconds= DateLib.toMilliseconds('2d'); // 2*24*3600*1000
var milliseconds= DateLib.toMilliseconds('2d 5h'); // 2*24*3600*1000 + 5*3600*1000
var milliseconds= DateLib.toMilliseconds('55.3m'); // 55.3*60*1000
```
