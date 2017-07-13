# LG Cesium - NYC Demo Presentation

## CZML/ros_bridge Asset Construction

```json
[{
        "id": "document",
        "name": "articles",
        "version": "1.0",
        "feature-info-template": "tokyo.mst",
        "show-feature-info": true
},
{
      some original czml feature
      ...
      "uscs_message": {
            ....
      }
}]
```

Where `uscs_message` is director_api:

```json
{
  "description": "",
  "duration": 0,
  "external_resource": "",
  "long_description": "",
  "menu_color": "white",
  "name": "Statue of Liberty",
  "online_required": false,
  "resource_uri": "/director_api/scene/7526f322-9a4a-40c8-aca3-9143f95ff9d0/",
  "slug": "7526f322-9a4a-40c8-aca3-9143f95ff9d0",
  "windows": [
    {
      "activity": "video",
      "activity_config": {},
      "assets": [
        "https://www.youtube.com/watch?v=42yO2FUWL6A"
      ],
      "height": 1080,
      "presentation_viewport": "left_two",
      "slug": 793335838,
      "width": 800,
      "x_coord": 140,
      "y_coord": 40
    },
    {
      "activity": "browser",
      "activity_config": {},
      "assets": [
        "http://lg-head:8088/roscoe_assets/statue-of-liberty.jpg"
      ],
      "height": 800,
      "presentation_viewport": "left_three",
      "slug": -1783669212,
      "width": 800,
      "x_coord": 40,
      "y_coord": 40
    },
    {
      "activity": "browser",
      "activity_config": {},
      "assets": [
        "http://thestatueofliberty.com/"
      ],
      "height": 1840,
      "presentation_viewport": "right_two",
      "slug": -1909566123,
      "width": 1000,
      "x_coord": 40,
      "y_coord": 40
    }
  ]
}

```
