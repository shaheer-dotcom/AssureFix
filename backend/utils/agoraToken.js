const { RtcTokenBuilder, RtcRole } = require('agora-access-token');

/**
 * Generate Agora RTC token for voice call
 * @param {String} channelName - Unique channel name for the call
 * @param {String} uid - User ID (can be 0 for dynamic assignment)
 * @param {String} role - User role ('publisher' or 'subscriber')
 * @returns {String} Generated Agora token
 */
const generateAgoraToken = (channelName, uid = 0, role = 'publisher') => {
  const appId = process.env.AGORA_APP_ID;
  const appCertificate = process.env.AGORA_APP_CERTIFICATE;

  if (!appId || !appCertificate) {
    throw new Error('Agora App ID and App Certificate must be configured in environment variables');
  }

  // Token expiration time (24 hours from now)
  const expirationTimeInSeconds = 86400;
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  // Determine role
  const agoraRole = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

  // Build token
  const token = RtcTokenBuilder.buildTokenWithUid(
    appId,
    appCertificate,
    channelName,
    uid,
    agoraRole,
    privilegeExpiredTs
  );

  return token;
};

/**
 * Generate unique channel name for a call
 * @param {String} callerId - Caller user ID
 * @param {String} receiverId - Receiver user ID
 * @returns {String} Unique channel name
 */
const generateChannelName = (callerId, receiverId) => {
  // Create a consistent channel name regardless of who initiates the call
  const ids = [callerId.toString(), receiverId.toString()].sort();
  const timestamp = Date.now();
  return `call_${ids[0]}_${ids[1]}_${timestamp}`;
};

module.exports = {
  generateAgoraToken,
  generateChannelName
};
