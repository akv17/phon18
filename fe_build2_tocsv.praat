# init sound 
sound_name$ = "3"
file_name$ = sound_name$ + ".csv"
sound_tier_idx = 1
segment_tier_idx = 2
segment_division = 5
header$ = "sound, sound_idx, segment, segment_idx, time, pitch, intensity, f1, f2"
line_sep$ = "::"
n_formants = 6.0


procedure get_pitch: .time
    selectObject: "Pitch " + sound_name$
    .p = Get value at time: .time, "Hertz", "Linear"
endproc


procedure get_intensity: .time
    selectObject: "Intensity " + sound_name$
    .db = Get value at time: .time, "Cubic"
endproc


procedure get_formant: .n, .time
    selectObject: "Formant " + sound_name$
    .f = Get value at time: .n, .time, "Hertz", "Linear"
endproc


procedure stream: sound_label$, sound_idx, seg_label$, seg_idx, time, pitch, db, f1, f2
    appendFileLine: file_name$, sound_label$, ", ", sound_idx, ", ",
                                ... seg_label$, ", ", seg_idx, ", ",
                                ... time, ", ", pitch, ", ", db, ", ",
                                ... f1, ", ", f2
endproc 


procedure process_segment: seg_label$, seg_idx, start, end
    # seg_idx: segment's global index in *segments* tier

    sound_intr_idx = Get interval at time: sound_tier_idx, start + 0.0001
    sound_label$ = Get label of interval: sound_tier_idx, sound_intr_idx

    delta_t = end - start
    step = delta_t / segment_division
    
    @get_pitch: start
    p = get_pitch.p

    @get_intensity: start
    db = get_intensity.db

    @get_formant: 1, start
    f1 = get_formant.f

    @get_formant: 2, start
    f2 = get_formant.f

    @stream: sound_label$, sound_intr_idx, seg_label$, seg_idx, start, p, db, f1, f2
    
    time = start
    for j from 1 to 3
        time = time + step
        
        @get_pitch: time
        p = get_pitch.p
        
        @get_intensity: time
        db = get_intensity.db

        @get_formant: 1, time
        f1 = get_formant.f

        @get_formant: 2, time
        f2 = get_formant.f

        @stream: sound_label$, sound_intr_idx, seg_label$, seg_idx, time, p, db, f1, f2       
    endfor

    @get_pitch: end
    p = get_pitch.p

    @get_intensity: end
    db = get_intensity.db

    @get_formant: 1, end
    f1 = get_formant.f

    @get_formant: 2, end
    f2 = get_formant.f

    @stream: sound_label$, sound_intr_idx, seg_label$, seg_idx, end, p, db, f1, f2
    #appendFileLine: file_name$, line_sep$
endproc


writeFileLine: file_name$, header$
#appendFileLine: file_name$, ""

# build pitch
selectObject: "Sound " + sound_name$
To Pitch: 0, 50, 600

# build intensity
selectObject: "Sound " + sound_name$
To Intensity: 50, 0

# build formants
selectObject: "Sound " + sound_name$
To Formant (burg): 0.0, n_formants, 5500.0, 0.025, 30.0


selectObject: "TextGrid " + sound_name$
# iterate over intervals in *segments* tier
seg_intrs_num = Get number of intervals: segment_tier_idx
# tracking only non-empty intervals
seg_idx = 0
for i from 1 to seg_intrs_num
    selectObject: "TextGrid " + sound_name$
    c_seg$ = Get label of interval: segment_tier_idx, i
    if length(c_seg$) > 0
	#seg_idx = seg_idx + 1
        seg_start = Get starting point: segment_tier_idx, i
        seg_end = Get end point: segment_tier_idx, i
        @process_segment: c_seg$, i, seg_start, seg_end
    #else
    #    appendInfoLine: "SKIP"
    #    appendInfoLine: line_sep$
    endif
endfor


writeInfoLine: "DONE"

#writeInfoLine: "F2 values in range: ", start, end, step
#while c_step < end
#    c_time = c_step
#    f2 = Get value at time: 2, c_time, "Hertz", "Linear"
#    appendInfoLine: "time: ", c_time, " F2 val = ", f2
#    c_step = c_step + step
#endwhile 