vid = videoinput('gige', 1, 'Mono16');
src = getselectedsource(vid);

vid.ROIPosition = [0 0 2048 2]