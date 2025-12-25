const { generateChannelName } = require('../../utils/agoraToken');

describe('Agora Token Utility', () => {
  describe('generateChannelName', () => {
    it('should generate unique channel name with both user IDs', () => {
      const callerId = '507f1f77bcf86cd799439011';
      const receiverId = '507f1f77bcf86cd799439012';

      const channelName = generateChannelName(callerId, receiverId);

      expect(channelName).toContain('call_');
      expect(channelName).toContain(callerId);
      expect(channelName).toContain(receiverId);
    });

    it('should generate consistent channel name regardless of order', () => {
      const userId1 = '507f1f77bcf86cd799439011';
      const userId2 = '507f1f77bcf86cd799439012';

      const channelName1 = generateChannelName(userId1, userId2);
      const channelName2 = generateChannelName(userId2, userId1);

      // Both should contain the same sorted IDs
      const ids1 = channelName1.split('_').slice(1, 3).sort();
      const ids2 = channelName2.split('_').slice(1, 3).sort();

      expect(ids1).toEqual(ids2);
    });

    it('should generate different channel names for different calls', (done) => {
      const callerId = '507f1f77bcf86cd799439011';
      const receiverId = '507f1f77bcf86cd799439012';

      const channelName1 = generateChannelName(callerId, receiverId);
      
      // Wait a bit to ensure different timestamp
      setTimeout(() => {
        const channelName2 = generateChannelName(callerId, receiverId);
        expect(channelName1).not.toBe(channelName2);
        done();
      }, 10);
    });
  });
});
