General Settings:
    DiskLogger
    FrameGrabInterval
    FramesPerTrigger
    LoggingMode: [ {memory} | disk | disk&memory ]
    Name
    ROIPosition
    Tag
    Timeout
    UserData

  Color Space Settings
    BayerSensorAlignment: [ {grbg} | gbrg | rggb | bggr ]
    ReturnedColorSpace: [ rgb | {grayscale} | YCbCr | bayer ]

  Callback Function Settings:
    ErrorFcn: string -or- function handle -or- cell array
    FramesAcquiredFcn: string -or- function handle -or- cell array
    FramesAcquiredFcnCount
    StartFcn: string -or- function handle -or- cell array
    StopFcn: string -or- function handle -or- cell array
    TimerFcn: string -or- function handle -or- cell array
    TimerPeriod
    TriggerFcn: string -or- function handle -or- cell array

  Trigger Settings:
    TriggerFrameDelay
    TriggerRepeat

  Acquisition Sources:
    SelectedSourceName: [ {input1} ]