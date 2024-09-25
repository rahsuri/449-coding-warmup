import:py from mtllm.llms {OpenAI}
import:py from mtllm.llms {Ollama}

import:jac from rag {RagEngine}

glob openai_llm = OpenAI(model_name='gpt-4o');
glob llama_llm = Ollama(model_name='llama3.1');

glob rag_engine:RagEngine = RagEngine();

node Session {
    has id: str;
    has chat_history: list[dict];
    has status: int = 1;

    can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
    openai_llm_chat(
        message:'current message':str,
        chat_history: 'chat history':list[dict],
        agent_role:'role of the agent responding':str,
        context:'retrieved context from documents':list
    ) -> 'response':str by openai_llm();

    can 'Respond to message using chat_history as context and agent_role as the goal of the agent'
    llama_llm_chat(
        message:'current message':str,
        chat_history: 'chat history':list[dict],
        agent_role:'role of the agent responding':str,
        context:'retrieved context from documents':list
    ) -> 'response':str by llama_llm();
}

walker interact {
    has message: str;
    has session_id: str;
    has model: str;

    can init_session with `root entry {
         visit [-->](`?Session)(?id == self.session_id) else {
            session_node = here ++> Session(id=self.session_id, chat_history=[], status=1);
            print("Session Node Created");

            visit session_node;
        }
    }
    can chat with Session entry {
        here.chat_history.append({"role": "user", "content": self.message});
        data = rag_engine.get_from_chroma(query=self.message);

        if self.model == "openai" {
            response = here.openai_llm_chat(
                message=self.message,
                chat_history=here.chat_history,
                agent_role="You are a conversation agent designed to help users with their queries based on the documents provided",
                context=data
            );
            here.chat_history.append({"role": "assistant", "content": response});
            report {"response": response};
        } else {
            response = here.llama_llm_chat(
                message=self.message,
                chat_history=here.chat_history,
                agent_role="You are a conversation agent designed to help users with their queries based on the documents provided",
                context=data
            );
            here.chat_history.append({"role": "assistant", "content": response});
            report {"response": response};
        }
    }
}