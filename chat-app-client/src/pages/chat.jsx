import {
  ArrowButton,
  Avatar,
  ChatContainer,
  ConversationHeader,
  MainContainer,
  Message,
  MessageInput,
  MessageList,
} from "@chatscope/chat-ui-kit-react";

import "@chatscope/chat-ui-kit-styles/dist/default/styles.min.css";

import { useSubscription } from "react-stomp-hooks";
import { createAvatar, formatUsername } from "../utils/helpers";
import { useChat } from "../hooks/useChat";

const Chat = ({ user, logout }) => {
  const { data, sendMessage, onMessageReceived } = useChat(user);

  useSubscription("/topic/newMessage", onMessageReceived);

  const username = formatUsername(user?.fullName) || "User";

  return (
    <div className="zidd-app">

      {/* =========================
          TOP HEADER
          ========================= */}

      <header className="zidd-header">

        <div className="zidd-brand-section">

          <div className="zidd-brand">
            ZIDD{" "}
            <span className="zidd-brand-accent">
              2.0
            </span>
          </div>

          <div className="zidd-batch">
            BATCH 2 • BUILD • DEPLOY • COLLABORATE
          </div>

        </div>


        <div className="zidd-user-section">

          <Avatar
            src={createAvatar(user?.id)}
          />

          <div className="zidd-user-info">

            <div className="zidd-username">
              @{username}
            </div>

            <div className="zidd-online">
              <span className="zidd-online-dot">
                ●
              </span>{" "}
              Online
            </div>

          </div>


          <button
            className="zidd-logout"
            onClick={logout}
          >
            Logout
          </button>

        </div>

      </header>


      {/* =========================
          CHAT WINDOW
          ========================= */}

      <main className="zidd-chat-wrapper">

        <MainContainer>

          <ChatContainer>

            {/* =========================
                CHAT HEADER
                ========================= */}

            <ConversationHeader>

              <Avatar
                src={createAvatar(user?.id)}
              />

              <ConversationHeader.Content
                userName="ZIDD 2.0 — Team Chat"
                info="Batch 2 • Team Collaboration • DevOps Workspace"
              />

              <ConversationHeader.Actions>
                <ArrowButton onClick={logout} />
              </ConversationHeader.Actions>

            </ConversationHeader>


            {/* =========================
                MESSAGE LIST
                ========================= */}

            <MessageList loading={!data}>

              {/* =========================
                  EMPTY STATE
                  ========================= */}

              {data &&
                data.messages.length === 0 && (

                  <MessageList.Content className="zidd-empty-state">

                    <div className="zidd-empty-icon">
                      💬
                    </div>

                    <h3>
                      No messages yet
                    </h3>

                    <p>
                      Start the conversation with your
                      ZIDD Batch 2 team.
                    </p>

                  </MessageList.Content>

                )}


              {/* =========================
                  MESSAGES
                  ========================= */}

              {data &&
                data.messages.map((message, index) => {

                  const isMe =
                    message.user.id.toString() ===
                    user.id.toString();


                  const previousMessage =
                    data.messages[index - 1];


                  const nextMessage =
                    data.messages[index + 1];


                  const isFirst =
                    !previousMessage ||
                    previousMessage.user.id !==
                      message.user.id;


                  const isLast =
                    !nextMessage ||
                    nextMessage.user.id !==
                      message.user.id;


                  const formattedTime =
                    new Date(
                      message.createdAt
                    ).toLocaleString(
                      "en-US",
                      {
                        hour: "numeric",
                        minute: "numeric",
                      }
                    );


                  /*
                   * =========================
                   * INCOMING MESSAGE
                   * =========================
                   *
                   * Sender name is deliberately
                   * rendered OUTSIDE Chatscope's
                   * Message component.
                   *
                   * This avoids depending on
                   * Message.Header / sender rendering.
                   */

                  if (!isMe) {

                    return (
                      <div
                        key={
                          message.id || index
                        }
                        className="zidd-incoming-wrapper"
                      >

                        {/* Sender name */}

                        {isFirst && (
                          <div className="zidd-sender-name">
                            @{message.user.name || "User"}

                            <span className="zidd-message-time">
                              {formattedTime}
                            </span>
                          </div>
                        )}


                        {/* Actual message */}

                        <Message
                          model={{
                            message:
                              message.content,

                            sender:
                              message.user.name ||
                              "User",

                            sentTime:
                              formattedTime,

                            direction:
                              "incoming",

                            position:
                              isLast
                                ? "last"
                                : isFirst
                                ? "first"
                                : "normal",
                          }}

                          avatarSpacer={
                            !isLast
                          }

                          avatarPosition="tl"
                        >

                          {/* Avatar only on last
                              message of group */}

                          {isLast && (
                            <Avatar
                              status={
                                message.user
                                  .isOnline
                                  ? "available"
                                  : "dnd"
                              }

                              src={
                                message.user.avatar ||
                                createAvatar(
                                  message.user.id
                                )
                              }

                              name={
                                message.user.name ||
                                "User"
                              }
                            />
                          )}

                        </Message>

                      </div>
                    );

                  }


                  /*
                   * =========================
                   * OUTGOING MESSAGE
                   * =========================
                   */

                  return (
                    <Message
                      key={
                        message.id || index
                      }

                      model={{
                        message:
                          message.content,

                        sender:
                          username,

                        sentTime:
                          formattedTime,

                        direction:
                          "outgoing",

                        position:
                          isLast
                            ? "last"
                            : isFirst
                            ? "first"
                            : "normal",
                      }}
                    />
                  );

                })}

            </MessageList>


            {/* =========================
                MESSAGE INPUT
                ========================= */}

            <MessageInput
              placeholder="Message your ZIDD team..."
              onSend={sendMessage}
              attachButton={false}
            />

          </ChatContainer>

        </MainContainer>

      </main>

    </div>
  );
};

export default Chat;