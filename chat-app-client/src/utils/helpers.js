export const formatUsername = (name) => {
  return "@" + name.replace(" ", "").toLowerCase();
};

export const createAvatar = (name) => {
  return `https://api.dicebear.com/9.x/initials/svg?seed=${encodeURIComponent(
    name || "User"
  )}&backgroundColor=6366f1&fontFamily=Arial`;
};

export const messageMapper = (message) => {
  return {
    id: message.id,
    user: {
      id: message.userId,
      name: formatUsername(message.fullName),
      avatar: createAvatar(message.userId),
      isOnline: true,
    },
    content: message.content,
    createdAt: message.createdAt,
  };
};
