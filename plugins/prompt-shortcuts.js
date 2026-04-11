export const PromptShortcuts = async () => {
  return {
    "chat.message": async (_input, output) => {
      for (const part of output.parts) {
        if (part.type !== "text" || typeof part.text !== "string") continue

        part.text = part.text.replace(
          /\bqqq\b/g,
          "If something is unclear ask me questions and DO NOT ASSUME!",
        )
      }
    },
  }
}
