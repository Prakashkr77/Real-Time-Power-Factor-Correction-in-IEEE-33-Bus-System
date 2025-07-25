global accessToken
accessToken = 'sl.u.AF0QSnEyWLHwdAG4MmE2Yvx4NMusBfeJegN9X9bTwQvgMOlt8iWpA1fUueSwcX3xKdnruH80ars-xfuZPYVeJvdNHmNl9vZpzaaHj-95a_zUFHizUAjX1qaPwJQJfn40ojXhvnKfC8qyY8_9On1Dm0XJJnLl2TTb6-9YHS8VoJUD0POkMCsQRGTrHSq-FLbyIvdpb77erP4eqmnLR0qoeiwFHQyIQaTpPVVvJOcbKOvLCX0zml6NC4rM8LHLrQ0vLDdnkk6S26T7fnWuFn_LR9WmXnUdSS6gOd2phP4r_thPgTd6MQjzhDKR2XoroWiGoYg_DoInsVaUVKkq_oi4bSc3lHI6bx-04HoBGi6qJzvMSh3uqOvQWxkO09zvX7a1_Y-FRRWA1sSI2zfAorsc_8KXt8yRxF9cSVrKQllU-8eO86LTWNa73TyLSXCQBO_m4PjKtfgiZrtRF3hAHvM_DZVhXvzHj__GE2XG7IPFAAtUW1CehGgMd-2iOy8imARzRbUQKLpujZj_2SAT1sTwcy9tAbdIFhGeSnYH6E2Aj3ZB98PkjO2YxQzcF2s8drS-LgtSpWHSVMXx_W_m5WkaxhKIQgLdtqovrZG7uOw_xn6zbxsFOCWxpRrEMA8Twm68feE0-j-YALQ-rms3E4PNsSGFaHs6Xak_NpJ1Y3HsJfPeQlUzohMn8WPawctFZR0iLyre5J098n_Efcpdx7fC31XdnAuIxCp2G9og4KsrPnn5Hmjf94UwbEstO-3KbC-8-ODnKwguVyi-DECgh9U_um0lB_wLLMMzA1gpoBE2C1UZAoHhNjOLqfYIy8NVCh4cvxmkAnzt-XWYqPqhZx2JVntsvuVy-B9Nlxi0wvGZLFMtBf93_u6viaYWDG3t3Q1uXXorW37Tfi6nW2PeappfSP9Xf7rR22qQ7U98KgNe1GIcIQx4tGIPyzo1i34L_LQMgcicsLFIIGXq4MNWna7AUWXS6p6FFiuXJAL62nYLRUVWE6hnW4hv0Q9KB1f_MIorQ0V3di6TYRBea3A3XQMoSvWyqfykNOTpRoWpwEdjX8At4dCPwvQXMpRaias4HA__3HT3FaeWCutM9eWYUKW3Kin889Ft3HVcQ97RPw2EVGBq_YnU6b4l_NQ6w4YMoYI-E6Av4ZlBbl-IJqI1VScyOPyT2O0e1bcWrP_Vz4kp4rzMGk4Tmg32PKRZuikn4xeJyv9OIVhR8qUimumNNjzsBQv8m4trZ_ESlL3CVpzfqVYhk4oY5qh9gfO4d2yn9O5yeY_FnTaZevnzPJsvb9t63XchuW4SaJPkNwK9rH9biUp_GXJZbmWr8CRxu4Mtkga9wLs-Xx8WCpuEu5QbBnY1SuOamdUg-WV9_i40KBUj9YZyazmVbTwbkyrjS4fup2sfSCAi9GU8_4qaf8QF2i2rSLHc3BxERT9f8KMsImceof8khQ';


% Initialize empty matrices
numBuses = 33;
sampleLength = length(out.I1abc.signals(1).values);
[Ia, Ib, Ic] = deal(zeros(sampleLength, numBuses));
[Va, Vb, Vc] = deal(zeros(sampleLength, numBuses));


% Extract all current and voltage data
for bus = 1:numBuses
    % Currents
    Ia(:,bus) = out.(['I' num2str(bus) 'abc']).signals(1).values;
    Ib(:,bus) = out.(['I' num2str(bus) 'abc']).signals(2).values;
    Ic(:,bus) = out.(['I' num2str(bus) 'abc']).signals(3).values;
    
    % Voltages
    Va(:,bus) = out.(['V' num2str(bus) 'abc']).signals(1).values;
    Vb(:,bus) = out.(['V' num2str(bus) 'abc']).signals(2).values;
    Vc(:,bus) = out.(['V' num2str(bus) 'abc']).signals(3).values;
end

% --- PF Summary Table ---
PF_summary = table();
PF_summary.Bus = (1:numBuses)';
PF_summary.PF_overall = zeros(numBuses, 1);
PF_summary.Comp_kVAR = zeros(numBuses, 1);
PF_summary.Active_kW = zeros(numBuses, 1);   
PF_summary.Action = strings(numBuses, 1);


% --- Compute PFs & Compensation per Bus ---
for i = 1:numBuses
    I_bus = [Ia(:,i), Ib(:,i), Ic(:,i)];
    V_bus = [Va(:,i), Vb(:,i), Vc(:,i)];

    % Call power calculation function (modified version)
    [P_avg, Q_avg, S_avg, PF_bus] = compute_bus_power(I_bus, V_bus);

    PF_summary.PF_overall(i) = PF_bus;
    PF_summary.Active_kW(i) = round(P_avg, 4);
    fprintf('Bus %2d: Active Power = %.4f kW\n', i, P_avg);

    if PF_bus < 0.95
        Q_required = P_avg * (tan(acos(PF_bus)) - tan(acos(0.95)));
        PF_summary.Comp_kVAR(i) = round(Q_required, 4);
        PF_summary.Action(i) = "Needs Compensation";
    else
        PF_summary.Comp_kVAR(i) = 0;
        PF_summary.Action(i) = "No Action";
    end
end

writetable(PF_summary, 'pf_3rdIter.csv');
% upload_encrypted_to_dropbox('pf_befor_corre8.csv', '/encryptpf_befor_corre8.csv.csv', 'TheFinalDataSet');


% Modified power calculation function (no time_step needed)
function [P_avg, Q_avg, S_avg, PF_bus] = compute_bus_power(I_bus, V_bus)
    % Ensure 3 phases (a, b, c)
    assert(size(I_bus, 2) == 3 && size(V_bus, 2) == 3, 'Data must contain 3 phases');
    
    % Compute instantaneous total power (sum of all phases)
    P_inst = V_bus(:,1).*I_bus(:,1) + V_bus(:,2).*I_bus(:,2) + V_bus(:,3).*I_bus(:,3);
    
    % Compute reactive power using Hilbert transform (all phases)
    Vh_a = imag(hilbert(V_bus(:,1)));
    Vh_b = imag(hilbert(V_bus(:,2)));
    Vh_c = imag(hilbert(V_bus(:,3)));
    Q_inst = Vh_a.*I_bus(:,1) + Vh_b.*I_bus(:,2) + Vh_c.*I_bus(:,3);
    
    % Average over time (3 lakh samples)
    P_total = mean(P_inst);  % Total active power (W)
    Q_total = mean(Q_inst);  % Total reactive power (VAR)
    
    % Convert to kW/kVAR
    P_avg = P_total / 1000;
    Q_avg = Q_total / 1000;
    S_avg = sqrt(P_avg^2 + Q_avg^2);
    
    % Power factor (from TOTAL power)
    PF_bus = P_avg / S_avg;
end

function upload_encrypted_to_dropbox(localFile, dropboxPath, encryptionKey)
    global accessToken
    
    % Read file data as binary
    fileData = fileread(localFile);
    
    % Generate key if not provided
    if nargin < 3 || isempty(encryptionKey)
        encryptionKey = char(java.util.UUID.randomUUID().toString().replace('-',''));
        fprintf('🔑 Generated encryption key: %s\nStore this securely!\n', encryptionKey);
    end
    
    % Encrypt the data
    encryptedData = encrypt_aes(fileData, encryptionKey);
    
    % Create HTTP options
    options = matlab.net.http.HTTPOptions(...
        'UseProxy', false, ...
        'ConnectTimeout', 30);
    
    % Create headers
    headers = matlab.net.http.HeaderField(...
        'Authorization', ['Bearer ' accessToken],...
        'Dropbox-API-Arg', jsonencode(struct(...
            'path', dropboxPath,...
            'mode', 'overwrite',...
            'autorename', true,...
            'mute', false)),...
        'Content-Type', 'application/octet-stream');
    
    % Convert encrypted data to proper format
    body = matlab.net.http.MessageBody;
    body.Payload = encryptedData(:);
    
    % Create and send request
    request = matlab.net.http.RequestMessage('POST', headers, body);
    
    try
        response = send(request,...
            matlab.net.URI('https://content.dropboxapi.com/2/files/upload'),...
            options);
        
        if response.StatusCode == matlab.net.http.StatusCode.OK
            disp('✅ Encrypted file successfully uploaded to Dropbox!');
        else
            error('Upload failed with status: %s', response.StatusLine.ReasonPhrase);
        end
    catch ME
        error('Upload failed: %s', ME.message);
    end
end

function encrypted = encrypt_aes(data, key)
    % AES-256 encryption
    import javax.crypto.*
    import javax.crypto.spec.*
    
    % Pad key to 32 bytes (256-bit)
    keyBytes = uint8(key);
    keyBytes = keyBytes(1:min(32,end));
    keyBytes = [keyBytes zeros(1, 32-length(keyBytes), 'uint8')];
    
    % Set up cipher
    cipher = Cipher.getInstance('AES/CBC/PKCS5Padding');
    iv = IvParameterSpec(zeros(1,16,'uint8'));
    cipher.init(Cipher.ENCRYPT_MODE, SecretKeySpec(keyBytes, 'AES'), iv);
    
    % Encrypt and ensure uint8 column vector
    encrypted = cipher.doFinal(uint8(data));
    encrypted = typecast(encrypted(:), 'uint8'); % Ensure uint8 output
end

% writecell(branches, '33_busBranch_detail.csv');
% upload_encrypted_to_dropbox('33_busBranch_detail.csv', '/secure_33_busBranch_detail.csv', 'powersystemModelMNNIT');
% writetable(PF_summary, 'pf_summary.csv');
% upload_encrypted_to_dropbox('pf_summary.csv', '/secure_pf_summary.csv', 'powersystemModelMNNIT');
