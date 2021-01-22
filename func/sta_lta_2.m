function events = sta_lta_2(wave,edp,type)
%
%STA_LTA_2: Short-Time-Average/Long-Time-Average event detector.
%
%UNIQUE: After event trigger, sta is tracked while lta window grows left 
%  edge of LTA windows remains fixed, but right edge of LTA window moves 
%  right until STA/LTA ratio drops below threshold (detriggers). After an
%  event is captured, LTA window returns to its original size        
%
%USAGE: events = sta_lta_2(wave,edp,type)
%
%DIAGRAM:
%                       /\      /\/\        /\
%              /\  /\/\/  \/\  /    \/\    /  \/\
%                \/          \/        \/\/      \
%                                           |-STA-| -->
%         --> |-----------------LTA---------------| -->
%
%INPUTS: wave - a waveform object containing events (maybe)
%        edp - Event Detection Parameters (1x6 double)
%        type - return type:
%                  'sst' - return event start/stop times (nx2)
%                  'wfa' - return event waveform array (nx1)
%                  'ssd' - return event start/stop datapoints (nx2)
%
%OUTPUTS: events - waveform object array of detected events

% Author: Dane Ketner, Alaska Volcano Observatory
% $Date$
% $Revision$

%% Initialize Waveform Variables

v = get(wave,'data');          % Waveform data
Fs = get(wave,'freq');         % Sampling frequency
l_v = get(wave,'data_length'); % Length of time series
tv = get(wave, 'timevector');  % Time vector of waveform
abs_v = abs(v);                % Absolute value of time series

%% Event Detection Parameters
l_sta = edp(1)*Fs;   % STA window size
l_lta = edp(2)*Fs;   % LTA window size
ll_lta = l_lta;      % Current length of growing LTA window
th_on = edp(3);      % Trigger on when sta_to_lta exceeds this theshold
th_off = edp(4);     % Trigger off when sta_to_lta drops below threshold
% for off_dur data points
skip_int = edp(5)*Fs;% Skip ahead after end of event (seconds)
min_dur = edp(6)*Fs; % Any triggers longer than min_dur become events

%% Initialize flags and other variables
lta_calc_flag = 0;       % has the full LTA window been calculated?
ntrig = 0;               % number of triggers
trig_array = zeros(1,2); % array of trigger times: [on,off;on,off;...]

%% Loops over data
% i is the primary reference point (right end of STA/LTA window)
i = l_lta+1;
while i <= l_v

%% Skip data gaps (NaN values in LTA window)?
   if any(isnan(abs_v(i-l_lta:i)))
      gap = 1;
      lta_calc_flag = 0; % Force full claculations after gap
      while gap == 1
         if i <= l_v, i = i+1; end
         if ~any(isnan(abs_v(i-l_lta:i)))
            gap = 0;
         end
      end
   end

%% Calculate STA & LTA Sum (Full)?
   if (lta_calc_flag == 0)
      lta_sum = 0;
      sta_sum = 0;
      for j = i-l_lta:i-1              % Loop to compute LTA & STA
         lta_sum = lta_sum + abs_v(j); % Sum LTA window
         if (i - j) <= l_sta           % Sum STA window (right side of LTA)
            sta_sum = sta_sum + abs_v(j);
         end
      end
      lta_calc_flag = 1;
   else
%% Calculate STA & LTA Sum (Single new data point) if not Full
      lta_sum = lta_sum - abs_v(i-l_lta-1) + abs_v(i-1);
      sta_sum = sta_sum - abs_v(i-l_sta-1) + abs_v(i-1);
   end

%% Calculate STA & LTA
   lta = lta_sum/l_lta;
   sta = sta_sum/l_sta;

%% Calculate STA/LTA Ratio
   sta_to_lta = sta/lta;

%% Trigger on? (Y/N)
   if sta_to_lta > th_on
      j = i;        % Set secondary reference point = primary
      while (sta_to_lta > th_off) % Track STA while LTA left edge static
         j = j+1;
         if j < l_v
            sta_sum = sta_sum - abs_v(j-l_sta-1) + abs_v(j-1);
            lta_sum = lta_sum + abs_v(j-1);
            ll_lta = ll+lta+1;
            sta = sta_sum/l_sta;
            lta = lta_sum/ll_lta;
            sta_to_lta = sta/lta;
            
            %% Skip data gaps (NaN values in STA window)?
            if any(isnan(abs_v(j-l_sta:j)))
               sta_to_lta = 0; % Force trigger off (data gap in STA window)
            end
            
         else
            sta_to_lta = 0; % Force trigger off (end of data)
         end
      end
      duration = (j-i);

%% Triggered period long enough? (Y/N)
      if duration > min_dur % If duration < min_dur then skip it
         trig_t = i-l_sta;  % Beginning of STA window during trigger on
         end_t  = j;        % End of STA window during trigger off
         ntrig = ntrig + 1; % Event counter
         trig_array(ntrig,:) = [trig_t, end_t];
      end
      ll_lta = l_lta;
      i = j + skip_int;  % Skip ahead
      lta_calc_flag = 0; % Reset LTA calc flag to force new computation
   end
   i = i + 1;
end

%% Return events
if (trig_array(1,1)==0)&&(trig_array(1,2)==0)
   disp('No events detected')
   return
end

switch lower(type)
   case {'ssd'}
      events = trig_array;
   case {'sst'}
      events = tv(trig_array);
   case {'wfa'}
      for n=1:size(trig_array,1)
         %fix = [2 5]; Fix event length to 2 seconds before trig on, 5 seconds
         %after trig on (All event are 7 seconds long), Change 'fix' as needed
         %events=[events;extract(wave,'INDEX',trig_array(n,1)-Fs*fix(1),...
         %                                    trig_array(n,1)+Fs)*fix(2)];
         events=[events; extract(wave,'INDEX',trig_array(n,1),trig_array(n,2))];
      end
   otherwise
      events = trig_array;
end