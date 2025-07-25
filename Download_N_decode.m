function decrypt_from_dropbox()
    % --- 1. Download from Dropbox ---
    encryptedFile = 'securepf_summary.csv';
    
    % --- 2. Load Encryption Key ---
    key = input('Enter decryption key: ', 's');
    
    % --- 3. Read & Decrypt (as binary) ---
    fid = fopen(encryptedFile, 'rb');
    encryptedData = fread(fid, '*uint8')';
    fclose(fid);
    
    decryptedData = decrypt_aes(encryptedData, key);
    
    % --- 4. Save to CSV ---
    outputFile = 'decryptedpf_detail.csv';
    fid = fopen(outputFile, 'w');
    fprintf(fid, '%s', decryptedData);
    fclose(fid);
    
    disp(['✅ Decrypted file saved as: ' outputFile]);
end

function decrypted = decrypt_aes(encryptedData, key)
    import javax.crypto.*
    import javax.crypto.spec.*
    
    % Pad key to 32 bytes (256-bit)
    keyBytes = uint8(key);
    keyBytes = keyBytes(1:min(32,end));
    keyBytes = [keyBytes zeros(1, 32-length(keyBytes), 'uint8')];
    
    % Set up cipher (match encryption settings)
    cipher = Cipher.getInstance('AES/CBC/PKCS5Padding');
    iv = IvParameterSpec(zeros(1,16,'uint8')); % Must match encryption IV
    cipher.init(Cipher.DECRYPT_MODE, SecretKeySpec(keyBytes, 'AES'), iv);
    
    % Decrypt (encryptedData should already be uint8)
    decryptedBytes = cipher.doFinal(encryptedData(:)); % Ensure column vector
    decrypted = char(decryptedBytes)';
end