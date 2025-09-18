

Qwen Key：
"sk-316420c29c624dbeb7fbbcb63077a46f"

or
"sk-1a28c3fcc7e044cbacd6faf47dc89755"


always use "qwen-plus" ,
no need to save token for me, *be cautions about the stream options or thinking options*


文本文

参考refer：
本文介绍通义千问 API 的输入输出参数。

> 模型介绍、选型建议和使用方法**，**请参考[文本生成](https://help.aliyun.com/zh/model-studio/text-generation)。

您可以通过 OpenAI 兼容或 DashScope 的方式调用通义千问 API。

## OpenAI 兼容

公有云

金融云

使用SDK调用时需配置的base_url：`https://dashscope.aliyuncs.com/compatible-mode/v1`

使用HTTP方式调用时需配置的endpoint：`POST https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions`

> 您需要已[获取API Key](https://help.aliyun.com/zh/model-studio/get-api-key)并[配置API Key到环境变量](https://help.aliyun.com/zh/model-studio/developer-reference/configure-api-key-through-environment-variables)。如果通过OpenAI SDK进行调用，还需要[安装SDK](https://help.aliyun.com/zh/model-studio/install-sdk/)。

|                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ### 请求体                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | 文本输入<br><br>流式输出<br><br>图像输入<br><br>视频输入<br><br>工具调用<br><br>联网搜索<br><br>异步调用<br><br>文档理解<br><br>文字提取<br><br>> 此处以单轮对话作为示例，您也可以进行[多轮对话](https://help.aliyun.com/zh/model-studio/multi-round-conversation)。<br><br>Python<br><br>Java<br><br>Node.js<br><br>Go<br><br>C#（HTTP）<br><br>PHP（HTTP）<br><br>curl<br><br>```python<br>import os<br>from openai import OpenAI<br><br><br>client = OpenAI(<br>    # 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",<br>    api_key=os.getenv("DASHSCOPE_API_KEY"),<br>    base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",<br>)<br><br>completion = client.chat.completions.create(<br>    # 模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models<br>    model="qwen-plus",<br>    messages=[<br>        {"role": "system", "content": "You are a helpful assistant."},<br>        {"role": "user", "content": "你是谁？"},<br>    ],<br>    # Qwen3模型通过enable_thinking参数控制思考过程（开源版默认True，商业版默认False）<br>    # 使用Qwen3开源版模型时，若未启用流式输出，请将下行取消注释，否则会报错<br>    # extra_body={"enable_thinking": False},<br>)<br>print(completion.model_dump_json())<br>``` |
| **model** `_string_` **（必选）**<br><br>模型名称。<br><br>支持的模型：通义千问大语言模型（商业版、开源版、Qwen-Long）、通义千问VL、通义千问Omni、数学模型、代码模型。<br><br>> 通义千问Audio暂不支持OpenAI兼容模式，仅支持[DashScope](https://help.aliyun.com/zh/model-studio/use-qwen-by-calling-api?mode=pure#a9b7b197e2q2v)方式。<br><br>**具体模型名称和计费，请参见**[模型列表](https://help.aliyun.com/zh/model-studio/models#9f8890ce29g5u)。                                                                                                                                                                                                                                               |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **messages** `_array_` **（必选）**<br><br>由历史对话组成的消息列表。<br><br>**消息类型**<br><br>System Message `_object_` （可选）<br><br>模型的目标或角色。如果设置系统消息，请放在messages列表的第一位。<br><br>**属性**<br><br>> QwQ 模型不建议设置 System Message，QVQ 模型设置System Message不会生效。<br><br>User Message `_object_` **（必选）**<br><br>用户发送给模型的消息。<br><br>**属性**<br><br>Assistant Message `_object_` （可选）<br><br>模型对用户消息的回复。<br><br>**属性**<br><br>Tool Message `_object_` （可选）<br><br>工具的输出信息。<br><br>**属性**                                                                                                                                               |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **stream** `_boolean_` （可选） 默认值为 `false`<br><br>是否流式输出回复。参数值：<br><br>- `false`：模型生成完所有内容后一次性返回结果。<br>    <br>- `true`：边生成边输出，即每生成一部分内容就立即输出一个片段（chunk）。您需要实时地逐个读取这些片段以获得完整的结果。<br>    <br><br>> Qwen3商业版（思考模式）、Qwen3开源版、QwQ、QVQ只支持流式输出。                                                                                                                                                                                                                                                                                                                                                                 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **stream_options** `_object_` （可选）<br><br>当启用流式输出时，可通过将本参数设置为`{"include_usage": true}`，在输出的最后一行显示所使用的Token数。<br><br>> 如果设置为false，则最后一行不显示使用的Token数。<br><br>本参数仅在设置stream为true时生效。                                                                                                                                                                                                                                                                                                                                                                                                                       |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **modalities** `array` （可选）默认值为`["text"]`<br><br>输出数据的模态，仅支持 [Qwen-Omni](https://help.aliyun.com/zh/model-studio/qwen-omni) 模型指定。可选值：<br><br>- `["text","audio"]`：输出文本与音频；<br>    <br>- `["text"]`：输出文本。                                                                                                                                                                                                                                                                                                                                                                                                |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **audio** `_object_` （可选）<br><br>输出音频的音色与格式，仅支持 [Qwen-Omni](https://help.aliyun.com/zh/model-studio/qwen-omni) 模型，且`modalities`参数需要包含`"audio"`。<br><br>**属性**                                                                                                                                                                                                                                                                                                                                                                                                                                           |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **temperature** `_float_` （可选）<br><br>采样温度，控制模型生成文本的多样性。<br><br>temperature越高，生成的文本更多样，反之，生成的文本更确定。<br><br>取值范围： [0, 2)<br><br>由于temperature与top_p均可以控制生成文本的多样性，因此建议您只设置其中一个值。更多说明，请参见[Temperature 和 top_p](https://help.aliyun.com/zh/model-studio/text-generation#ad7b336bec5fw)。<br><br>**temperature默认值**<br><br>> 不建议修改QVQ模型的默认temperature值 。                                                                                                                                                                                                                                                      |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **top_p** `_float_` （可选）<br><br>核采样的概率阈值，控制模型生成文本的多样性。<br><br>top_p越高，生成的文本更多样。反之，生成的文本更确定。<br><br>取值范围：（0,1.0]<br><br>由于temperature与top_p均可以控制生成文本的多样性，因此建议您只设置其中一个值。更多说明，请参见[Temperature 和 top_p](https://help.aliyun.com/zh/model-studio/text-generation#ad7b336bec5fw)。<br><br>**top_p默认值**<br><br>> 不建议修改QVQ模型的默认 top_p 值。                                                                                                                                                                                                                                                                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **top_k** `_integer_` （可选）<br><br>生成过程中采样候选集的大小。例如，取值为50时，仅将单次生成中得分最高的50个Token组成随机采样的候选集。取值越大，生成的随机性越高；取值越小，生成的确定性越高。取值为None或当top_k大于100时，表示不启用top_k策略，此时仅有top_p策略生效。<br><br>取值需要大于或等于0。<br><br>**top_k默认值**<br><br>> 通过 Python SDK调用时，请将 **top_k** 放入 **extra_body** 对象中，配置方式为：extra_body={"top_k":xxx}。<br><br>> 不建议修改QVQ模型的默认 top_k 值。                                                                                                                                                                                                                                                               |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **presence_penalty** `_float_` （可选）<br><br>控制模型生成文本时的内容重复度。<br><br>取值范围：[-2.0, 2.0]。正数会减少重复度，负数会增加重复度。<br><br>适用场景：<br><br>较高的presence_penalty适用于要求多样性、趣味性或创造性的场景，如创意写作或头脑风暴。<br><br>较低的presence_penalty适用于要求一致性或专业术语的场景，如技术文档或其他正式文档。<br><br>**presence_penalty默认值**<br><br>**原理介绍**<br><br>**示例**<br><br>> 使用qwen-vl-plus、qwen-vl-plus-2025-01-25模型进行文字提取时，建议设置presence_penalty为1.5。<br><br>> 不建议修改QVQ模型的默认presence_penalty值。                                                                                                                                                                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **response_format** `_object_` （可选） 默认值为`{"type": "text"}`<br><br>返回内容的格式。可选值：`{"type": "text"}`或`{"type": "json_object"}`。设置为`{"type": "json_object"}`时会输出标准格式的JSON字符串。使用方法请参见：[结构化输出](https://help.aliyun.com/zh/model-studio/json-mode)。<br><br>> 如果指定该参数为`{"type": "json_object"}`，您需要在System Message或User Message中指引模型输出JSON格式，如：“请按照json格式输出。”<br><br>支持的模型                                                                                                                                                                                                                                       |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **max_tokens** `_integer_` （可选）<br><br>本次请求返回的最大 Token 数。<br><br>> `max_tokens` 的设置不会影响大模型的生成过程，如果模型生成的 Token 数超过`max_tokens`，本次请求会返回截断后的内容。<br><br>默认值和最大值都是模型的最大输出长度。关于各模型的最大输出长度，请参见[模型列表](https://help.aliyun.com/zh/model-studio/models#9f8890ce29g5u)。<br><br>max_tokens参数适用于需要限制字数（如生成摘要、关键词）、控制成本或减少响应时间的场景。<br><br>> 对于qwen-vl-ocr-2025-04-13、qwen-vl-ocr-latest模型，max_tokens默认值为2048，最大值为8192。<br><br>> 对于 QwQ、QVQ 与开启思考模式的 Qwen3 模型，`max_tokens`会限制回复内容的长度，不限制深度思考内容的长度。                                                                                                                     |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **n** `_integer_` （可选） 默认值为1<br><br>生成响应的个数，取值范围是`1-4`。对于需要生成多个响应的场景（如创意写作、广告文案等），可以设置较大的 n 值。<br><br>> 当前仅支持 qwen-plus 与 [Qwen3（非思考模式）](https://help.aliyun.com/zh/model-studio/deep-thinking#be9890136awsc) 模型，且在传入 tools 参数时固定为1。<br><br>> 设置较大的 n 值不会增加输入 Token 消耗，会增加输出 Token 的消耗。                                                                                                                                                                                                                                                                                                                 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **enable_thinking** `_boolean_` （可选）<br><br>是否开启思考模式，适用于 Qwen3 模型。<br><br>Qwen3 商业版模型默认值为 False，Qwen3 开源版模型默认值为 True。<br><br>> 通过 Python SDK 调用时，请通过`extra_body`配置。配置方式为：`extra_body={"enable_thinking": xxx}`。                                                                                                                                                                                                                                                                                                                                                                                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **thinking_budget** `_integer_` （可选）<br><br>思考过程的最大长度，只在`enable_thinking`为`true`时生效。适用于 Qwen3 的商业版与开源版模型。详情请参见[限制思考长度](https://help.aliyun.com/zh/model-studio/deep-thinking#e7c0002fe4meu)。<br><br>> 通过 Python SDK 调用时，请通过`extra_body`配置。配置方式为：`extra_body={"thinking_budget": xxx}`。                                                                                                                                                                                                                                                                                                                  |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **seed** `_integer_` （可选）<br><br>设置seed参数会使文本生成过程更具有确定性，通常用于使模型每次运行的结果一致。<br><br>在每次模型调用时传入相同的seed值（由您指定），并保持其他参数不变，模型将尽可能返回相同的结果。<br><br>取值范围：0到231−1。<br><br>**seed默认值**                                                                                                                                                                                                                                                                                                                                                                                                                              |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **stop** `_string 或 array_` （可选）<br><br>使用stop参数后，当模型生成的文本即将包含指定的字符串或token_id时，将自动停止生成。<br><br>您可以在stop参数中传入敏感词来控制模型的输出。<br><br>> stop为array类型时，不可以将token_id和字符串同时作为元素输入，比如不可以指定stop为`["你好",104307]`。                                                                                                                                                                                                                                                                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **tools** `_array_` （可选）<br><br>可供模型调用的工具数组，可以包含一个或多个工具对象。一次Function Calling流程模型会从中选择一个工具（开启[parallel_tool_calls](https://help.aliyun.com/zh/model-studio/use-qwen-by-calling-api?mode=pure#df816f8ec85ry)可以选择多个工具）。<br><br>> 目前不支持通义千问VL/Audio，也不建议用于数学和代码模型。<br><br>**属性**                                                                                                                                                                                                                                                                                                                            |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **tool_choice** `_string 或 object_` （可选）默认值为 `"auto"`<br><br>如果您希望对于某一类问题，大模型能够采取制定好的工具选择策略（如强制使用某个工具、强制使用至少一个工具、强制不使用工具等），可以通过修改`tool_choice`参数来强制指定工具调用的策略。可选值：<br><br>- `"auto"`<br>    <br>    表示由大模型进行工具策略的选择。<br>    <br>- `"none"`<br>    <br>    如果您希望无论输入什么问题，Function Calling 都不会进行工具调用，可以设定`tool_choice`参数为`"none"`；<br>    <br>- `{"type": "function", "function": {"name": "the_function_to_call"}}`<br>    <br>    如果您希望对于某一类问题，Function Calling 能够强制调用某个工具，可以设定`tool_choice`参数为`{"type": "function", "function": {"name": "the_function_to_call"}}`，其中`the_function_to_call`是您指定的工具函数名称。 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **parallel_tool_calls** `_boolean_` （可选）默认值为 `false`<br><br>是否开启并行工具调用。参数为`true`时开启，为`false`时不开启。并行工具调用详情请参见：[并行工具调用](https://help.aliyun.com/zh/model-studio/qwen-function-calling#cb6b5c484bt4x)。                                                                                                                                                                                                                                                                                                                                                                                                     |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **translation_options** `_object_` （可选）<br><br>当您使用[翻译模型](https://help.aliyun.com/zh/model-studio/machine-translation)时需要配置的翻译参数。<br><br>**属性**<br><br>> 若您通过Python SDK调用，请通过extra_body配置。配置方式为：`extra_body={"translation_options": xxx}`。                                                                                                                                                                                                                                                                                                                                                              |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **enable_search** `_boolean_` （可选）<br><br>模型在生成文本时是否使用互联网搜索结果进行参考。取值如下：<br><br>- true：启用互联网搜索，模型会将搜索结果作为文本生成过程中的参考信息，但模型会基于其内部逻辑判断是否使用互联网搜索结果。<br>    <br>    > 如果模型没有搜索互联网，建议优化Prompt，或设置`search_options`中的`forced_search`参数开启强制搜索。<br>    <br>- false（默认）：关闭互联网搜索。<br>    <br><br>> 启用互联网搜索功能可能会增加 Token 的消耗。<br><br>> 若您通过 Python SDK调用，请通过`extra_body`配置。配置方式为：`extra_body={"enable_search": True}`。<br><br>**支持的模型**                                                                                                                                                                               |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **search_options** `_object_` （可选）<br><br>联网搜索的策略。仅当`enable_search`为`true`时生效。<br><br>**属性**<br><br>> 若您通过 Python SDK调用，请通过`extra_body`配置。配置方式为：`extra_body={"search_options": xxx}`。                                                                                                                                                                                                                                                                                                                                                                                                                   |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| **X-DashScope-DataInspection** `_string_` （可选）<br><br>在通义千问 API 的内容安全能力基础上，是否进一步识别输入输出内容的违规信息。取值如下：<br><br>- `'{"input":"cip","output":"cip"}'`：进一步识别；<br>    <br>- 不设置该参数：不进一步识别。<br>    <br><br>通过 HTTP 调用时请放入请求头：`-H "X-DashScope-DataInspection: {\"input\": \"cip\", \"output\": \"cip\"}"`；<br><br>通过 Python SDK 调用时请通过`extra_headers`配置：`extra_headers={'X-DashScope-DataInspection': '{"input":"cip","output":"cip"}'}`。<br><br>详细使用方法请参见[内容安全](https://help.aliyun.com/zh/model-studio/content-security)。<br><br>> 不支持通过 Node.js SDK设置。<br><br>> 不适用于 Qwen-VL 系列模型。                            |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |

|                                                                          |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ### chat响应对象（非流式输出）                                                      | ```json<br>{<br>    "choices": [<br>        {<br>            "message": {<br>                "role": "assistant",<br>                "content": "我是阿里云开发的一款超大规模语言模型，我叫通义千问。"<br>            },<br>            "finish_reason": "stop",<br>            "index": 0,<br>            "logprobs": null<br>        }<br>    ],<br>    "object": "chat.completion",<br>    "usage": {<br>        "prompt_tokens": 3019,<br>        "completion_tokens": 104,<br>        "total_tokens": 3123,<br>        "prompt_tokens_details": {<br>            "cached_tokens": 2048<br>        }<br>    },<br>    "created": 1735120033,<br>    "system_fingerprint": null,<br>    "model": "qwen-plus",<br>    "id": "chatcmpl-6ada9ed2-7f33-9de2-8bb0-78bd4035025a"<br>}<br>``` |
| **id** `_string_`<br><br>本次调用的唯一标识符。                                     |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **choices** `_array_`<br><br>模型生成内容的数组，可以包含一个或多个choices对象。<br><br>**属性** |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **created** `_integer_`<br><br>本次chat请求被创建时的时间戳。                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **model** `_string_`<br><br>本次chat请求使用的模型名称。                             |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **object** `_string_`<br><br>始终为`chat.completion`。                       |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **service_tier** `_string_`<br><br>该参数当前固定为`null`。                       |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **system_fingerprint** `_string_`<br><br>该参数当前固定为`null`。                 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| **usage** `_object_`<br><br>本次chat请求使用的 Token 信息。<br><br>**属性**          |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |

|   |   |
|---|---|
|### chat响应chunk对象（流式输出）|```json<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"","function_call":null,"refusal":null,"role":"assistant","tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"我是","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"来自","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"阿里","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"云的超大规模","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"语言模型，我","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"叫通义千","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"问。","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":"stop","index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":{"completion_tokens":17,"prompt_tokens":22,"total_tokens":39,"completion_tokens_details":null,"prompt_tokens_details":{"audio_tokens":null,"cached_tokens":0}}}<br>```|
|**id** `_string_`<br><br>本次调用的唯一标识符。每个chunk对象有相同的 id。|
|**choices** `_array_`<br><br>模型生成内容的数组，可包含一个或多个choices对象。如果设置`include_usage`参数为`true`，则最后一个chunk为空。<br><br>**属性**|
|**created** `_integer_`<br><br>本次chat请求被创建时的时间戳。每个chunk对象有相同的时间戳。|
|**model** `_string_`<br><br>本次chat请求使用的模型名称。|
|**object** `_string_`<br><br>始终为`chat.completion.chunk`。|
|**service_tier** `_string_`<br><br>该参数当前固定为`null`。|
|**system_fingerprint**`_string_`<br><br>该参数当前固定为`null`。|
|**usage** `_object_`<br><br>本次chat请求使用的Token信息。只在`include_usage`为`true`时，在最后一个chunk显示。<br><br>**属性**|

## DashScope

公有云

金融云

**通过HTTP调用时需配置的endpoint：**

使用通义千问大语言模型：`POST https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation`

使用通义千问VL或通义千问Audio模型：`POST https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation`

> 您需要已[获取API Key](https://help.aliyun.com/zh/model-studio/get-api-key)并[配置API Key到环境变量](https://help.aliyun.com/zh/model-studio/developer-reference/configure-api-key-through-environment-variables)。如果通过DashScope SDK进行调用，还需要[安装DashScope SDK](https://help.aliyun.com/zh/model-studio/install-sdk/#f3e80b21069aa)。

|   |   |
|---|---|
|### 请求体|文本输入<br><br>流式输出<br><br>图像输入<br><br>视频输入<br><br>音频输入<br><br>联网搜索<br><br>工具调用<br><br>异步调用<br><br>文字提取<br><br>> 此处以单轮对话作为示例，您也可以进行[多轮对话](https://help.aliyun.com/zh/model-studio/multi-round-conversation)。<br><br>Python<br><br>Java<br><br>PHP（HTTP）<br><br>Node.js（HTTP）<br><br>C#（HTTP）<br><br>Go（HTTP）<br><br>curl<br><br>```python<br>import os<br>import dashscope<br><br>messages = [<br>    {'role': 'system', 'content': 'You are a helpful assistant.'},<br>    {'role': 'user', 'content': '你是谁？'}<br>    ]<br>response = dashscope.Generation.call(<br>    # 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",<br>    api_key=os.getenv('DASHSCOPE_API_KEY'),<br>    model="qwen-plus", # 此处以qwen-plus为例，可按需更换模型名称。模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models<br>    messages=messages,<br>    result_format='message'<br>    )<br>print(response)<br>```|
|**model** `_string_` **（必选）**<br><br>模型名称。<br><br>支持的模型：通义千问大语言模型（商业版、开源版、Qwen-Long）、通义千问VL、通义千问Audio、数学模型、代码模型<br><br>**具体模型名称和计费，请参见**[模型列表](https://help.aliyun.com/zh/model-studio/models#9f8890ce29g5u)。|
|**messages** `_array_` **（必选）**<br><br>由历史对话组成的消息列表。<br><br>> 通过HTTP调用时，请将**messages** 放入 **input** 对象中。<br><br>**消息类型**|
|**temperature** `_float_` （可选）<br><br>采样温度，控制模型生成文本的多样性。<br><br>temperature越高，生成的文本更多样，反之，生成的文本更确定。<br><br>取值范围： [0, 2)<br><br>**temperature默认值**<br><br>> 通过HTTP调用时，请将 **temperature** 放入 **parameters** 对象中。<br><br>> 不建议修改QVQ模型的默认 temperature 值。|
|**top_p** `_float_` （可选）<br><br>核采样的概率阈值，控制模型生成文本的多样性。<br><br>top_p越高，生成的文本更多样。反之，生成的文本更确定。<br><br>取值范围：（0,1.0]。<br><br>**top_p默认值**<br><br>> Java SDK中为**topP**_。_通过HTTP调用时，请将 **top_p** 放入 **parameters** 对象中。<br><br>> 不建议修改QVQ模型的默认 top_p 值。|
|**top_k** `_integer_` （可选）<br><br>生成过程中采样候选集的大小。例如，取值为50时，仅将单次生成中得分最高的50个Token组成随机采样的候选集。取值越大，生成的随机性越高；取值越小，生成的确定性越高。取值为None或当top_k大于100时，表示不启用top_k策略，此时仅有top_p策略生效。<br><br>取值需要大于或等于0。<br><br>**top_k默认值**<br><br>> Java SDK中为**topK**_。_通过HTTP调用时，请将 **top_k** 放入 **parameters** 对象中。<br><br>> 不建议修改QVQ模型的默认 top_k 值。|
|**enable_thinking** `_boolean_` （可选）<br><br>是否开启思考模式，适用于 Qwen3 商业版与开源版模型。<br><br>Qwen3 开源版默认值为 True，Qwen3 商业版模型默认值为 False。<br><br>> Java SDK 为enableThinking；通过HTTP调用时，请将 **enable_thinking** 放入 **parameters** 对象中。|
|**thinking_budget** `_integer_` （可选）<br><br>思考过程的最大长度，在`enable_thinking`为`true`时生效，适用于qwen-plus-2025-04-28、qwen-plus-latest、qwen-turbo-2025-04-28、qwen-turbo-latest 与 Qwen3 全系模型。详情请参见[限制思考长度](https://help.aliyun.com/zh/model-studio/deep-thinking#e7c0002fe4meu)。|
|**repetition_penalty** `_float_` （可选）<br><br>模型生成时连续序列中的重复度。提高repetition_penalty时可以降低模型生成的重复度，1.0表示不做惩罚。没有严格的取值范围，只要大于0即可。<br><br>**repetition_penalty默认值**<br><br>> Java SDK中为**repetitionPenalty**_。_通过HTTP调用时，请将 **repetition_penalty** 放入 **parameters** 对象中。<br><br>> 使用qwen-vl-plus、qwen-vl-plus_2025-01-25模型进行文字提取时，建议设置repetition_penalty为1.0。<br><br>> 对于qwen-vl-ocr模型，repetition_penalty的默认值为1.05，该参数对模型效果影响较大，请勿随意修改。<br><br>> 不建议修改QVQ模型的默认 repetition_penalty 值。|
|**presence_penalty** `_float_` （可选）<br><br>控制模型生成文本时的内容重复度。<br><br>取值范围：[-2.0, 2.0]。正数会减少重复度，负数会增加重复度。<br><br>适用场景：<br><br>较高的presence_penalty适用于要求多样性、趣味性或创造性的场景，如创意写作或头脑风暴。<br><br>较低的presence_penalty适用于要求一致性或专业术语的场景，如技术文档或其他正式文档。<br><br>**presence_penalty默认值**<br><br>**原理介绍**<br><br>**示例**<br><br>> 使用qwen-vl-plus、qwen-vl-plus-2025-01-25模型进行文字提取时，建议设置presence_penalty为1.5。<br><br>> 不建议修改QVQ模型的默认presence_penalty值。<br><br>> Java SDK不支持设置该参数_。_通过HTTP调用时，请将 **presence_penalty** 放入 **parameters** 对象中。|
|**vl_high_resolution_images** `_boolean_` （可选）默认值为 false<br><br>是否提高输入图片的默认Token上限。输入图片的默认Token上限为1280，配置为true时输入图片的Token上限为16384。<br><br>**支持的模型**<br><br>> Java SDK不支持设置该参数_。_通过HTTP调用时，请将 **vl_high_resolution_images** 放入 **parameters** 对象中。|
|**ocr_options** `_object_` （可选）<br><br>当您使用通义千问OCR模型执行内置任务时需要配置的参数。<br><br>**属性**<br><br>> 设置该参数需保证DashScope Python SDK 最低版本为1.22.2， Java SDK 最低版本为2.18.4。<br><br>> 通过HTTP调用时，请将 **ocr_options** 放入 **parameters** 对象中。|
|**max_tokens** `_integer_` （可选）<br><br>本次请求返回的最大 Token 数。<br><br>> `max_tokens` 的设置不会影响大模型的生成过程，如果模型生成的 Token 数超过`max_tokens`，本次请求会返回截断后的内容。<br><br>默认值和最大值都是模型的最大输出长度。关于各模型的最大输出长度，请参见[模型列表](https://help.aliyun.com/zh/model-studio/models#9f8890ce29g5u)。<br><br>max_tokens参数适用于需要限制字数（如生成摘要、关键词）、控制成本或减少响应时间的场景。<br><br>> 对于qwen-vl-ocr-2025-04-13、qwen-vl-ocr-latest模型，max_tokens默认值为2048，最大值为8192。<br><br>> 对于 QwQ、QVQ 与开启思考模式的 Qwen3 模型，`max_tokens`会限制回复内容的长度，不限制深度思考内容的长度。<br><br>> 对于qwen-vl-ocr-2025-04-13、qwen-vl-ocr-latest模型，max_tokens默认值为2048，最大值为8192。<br><br>> Java SDK中为**maxTokens**（模型为通义千问VL/OCR/Audio/ASR时，Java SDK中为**maxLength，**在 2.18.4 版本之后支持也设置为 maxTokens）_。_通过HTTP调用时，请将 **max_tokens** 放入 **parameters** 对象中。|
|**seed** `_integer_` （可选）<br><br>设置seed参数会使文本生成过程更具有确定性，通常用于使模型每次运行的结果一致。<br><br>在每次模型调用时传入相同的seed值（由您指定），并保持其他参数不变，模型将尽可能返回相同的结果。<br><br>取值范围：0到231−1。<br><br>**seed默认值**<br><br>> 通过HTTP调用时，请将 **seed** 放入 **parameters** 对象中。|
|**stream** `_boolean_` （可选）<br><br>是否流式输出回复。参数值：<br><br>- false（默认值）：模型生成完所有内容后一次性返回结果。<br>    <br>- true：边生成边输出，即每生成一部分内容就立即输出一个片段（chunk）。<br>    <br><br>> 该参数仅支持Python SDK。通过Java SDK实现流式输出请通过`streamCall`接口调用；通过HTTP实现流式输出请在Header中指定`X-DashScope-SSE`为`enable`。<br><br>> Qwen3商业版（思考模式）、Qwen3开源版、QwQ、QVQ只支持流式输出。|
|**incremental_output** `_boolean_` （可选）默认为`false`（[Qwen3 开源版](https://help.aliyun.com/zh/model-studio/models#9d516d17965af)、[QwQ](https://help.aliyun.com/zh/model-studio/deep-thinking) 、[QVQ](https://help.aliyun.com/zh/model-studio/qvq)模型默认值为 `true`）<br><br>在流式输出模式下是否开启增量输出。参数值：<br><br>- false：每次输出为当前已经生成的整个序列，最后一次输出为生成的完整结果。<br>    <br>    ```plaintext<br>    I<br>    I like<br>    I like apple<br>    I like apple.<br>    ```<br>    <br>- true：增量输出，即后续输出内容不包含已输出的内容。您需要实时地逐个读取这些片段以获得完整的结果。<br>    <br>    ```plaintext<br>    I<br>    like<br>    apple<br>    .<br>    ```<br>    <br><br>> Java SDK中为**incrementalOutput**_。_通过HTTP调用时，请将 **incremental_output** 放入 **parameters** 对象中。<br><br>> QwQ 模型与思考模式下的 Qwen3 模型只支持设置为 `true`。由于 Qwen3 商业版模型默认值为`false`，您需要在思考模式下手动设置为 `true`。<br><br>> Qwen3 开源版模型不支持设置为 `false`。|
|**response_format** `_object_` （可选） 默认值为`{"type": "text"}`<br><br>返回内容的格式。可选值：`{"type": "text"}`或`{"type": "json_object"}`。设置为`{"type": "json_object"}`时会输出标准格式的JSON字符串。使用方法请参见：[结构化输出](https://help.aliyun.com/zh/model-studio/json-mode)。<br><br>> 如果指定该参数为`{"type": "json_object"}`，您需要在 System Message 或 User Message 中指引模型输出 JSON 格式，如：“请按照json格式输出。”<br><br>> 不支持通过 Java SDK 设置该参数。通过HTTP调用时，请将 **response_format** 放入 **parameters** 对象中。<br><br>支持的模型|
|**result_format** `_string_` （可选） 默认为`"text"`（[QwQ](https://help.aliyun.com/zh/model-studio/deep-thinking) 模型、Qwen3 开源模型与 Qwen-Long 模型默认值为 `"message"`）<br><br>返回数据的格式。推荐您优先设置为`"message"`，可以更方便地进行[多轮对话](https://help.aliyun.com/zh/model-studio/multi-round-conversation)。<br><br>> 平台后续将统一将默认值调整为"message"。<br><br>> Java SDK中为**resultFormat**_。_通过HTTP调用时，请将 **result_format** 放入 **parameters** 对象中。<br><br>> 模型为通义千问VL/QVQ/OCR/Audio/ASR时，设置“`text`”不生效。<br><br>> 思考模式下的 Qwen3 模型只能设置为`"message"`，由于 Qwen3 商业版模型默认值为"text"，您需要将其设置为`"message"`。<br><br>> 如果您使用 Java SDK 调用Qwen3 开源模型，并且传入了 "text"，依然会以 "message"格式进行返回。|
|**stop** `_string 或 array_` （可选）<br><br>使用stop参数后，当模型生成的文本即将包含指定的字符串或token_id时，将自动停止生成。<br><br>您可以在stop参数中传入敏感词来控制模型的输出。<br><br>> stop为array类型时，不可以将token_id和字符串同时作为元素输入，比如不可以指定stop为`["你好",104307]`。|
|**tools** `_array_` （可选）<br><br>可供模型调用的工具数组，可以包含一个或多个工具对象。一次 Function Calling 流程模型会从中选择其中一个工具（开启[parallel_tool_calls](https://help.aliyun.com/zh/model-studio/use-qwen-by-calling-api?mode=pure#5398ced61euxr)参数可能选择多个工具）。使用 tools 时需要同时指定`result_format`参数为`"message"`。无论是发起 Function Calling，还是向模型提交工具函数的执行结果，均需设置tools参数。<br><br>> 目前不支持通义千问VL/Audio，也不建议用于数学和代码模型。<br><br>**属性**<br><br>> 通过HTTP调用时，请将 **tools** 放入 **parameters** JSON 对象中。暂时不支持qwen-vl与qwen-audio系列模型。|
|**tool_choice** `_string 或 object_` （可选）<br><br>在使用tools参数时，用于控制模型调用指定工具。有三种取值：<br><br>- `"none"`表示不调用工具。tools参数为空时，默认值为`"none"`。<br>    <br>- `"auto"`表示由模型判断是否调用工具，可能调用也可能不调用。tools参数不为空时，默认值为`"auto"`。<br>    <br>- object结构可以指定模型调用的工具。例如`tool_choice={"type": "function", "function": {"name": "user_function"}}`。<br>    <br>    - type只支持指定为`"function"`。<br>        <br>    - function<br>        <br>        - name表示期望被调用的工具名称，例如`"get_current_time"`。<br>            <br><br>> Java SDK中为**toolChoice**_。_通过HTTP调用时，请将 **tool_choice** 放入 **parameters** 对象中。|
|**parallel_tool_calls** `_boolean_` （可选）默认值为 `false`<br><br>是否开启并行工具调用。参数为`true`时开启，为`false`时不开启。并行工具调用详情请参见：[并行工具调用](https://help.aliyun.com/zh/model-studio/qwen-function-calling#cb6b5c484bt4x)。|
|**translation_options** `_object_` （可选）<br><br>当您使用[翻译模型](https://help.aliyun.com/zh/model-studio/machine-translation)时需要配置的翻译参数。<br><br>**属性**<br><br>> Java SDK 暂不支持配置该参数。通过HTTP调用时，请将 **translation_options** 放入 **parameters** 对象中。|
|**enable_search** `_boolean_` （可选）<br><br>模型在生成文本时是否使用互联网搜索结果进行参考。取值如下：<br><br>- true：启用互联网搜索，模型会将搜索结果作为文本生成过程中的参考信息，但模型会基于其内部逻辑判断是否使用互联网搜索结果。<br>    <br>    > 如果模型没有搜索互联网，建议优化Prompt，或设置`search_options`中的`forced_search`参数开启强制搜索。<br>    <br>- false（默认）：关闭互联网搜索。<br>    <br><br>**支持的模型**<br><br>> Java SDK中为**enableSearch**_。_通过HTTP调用时，请将 **enable_search** 放入 **parameters** 对象中。<br><br>> 启用互联网搜索功能可能会增加 Token 的消耗。|
|**search_options** `_object_` （可选）<br><br>联网搜索的策略。仅当`enable_search`为`true`时生效。<br><br>> 通过HTTP调用时，请将 **search_options** 放入 **parameters** 对象中。Java SDK中为searchOptions。<br><br>**属性**|
|**X-DashScope-DataInspection** `_string_` （可选）<br><br>在通义千问 API 的内容安全能力基础上，是否进一步识别输入输出内容的违规信息。取值如下：<br><br>- `'{"input":"cip","output":"cip"}'`：进一步识别；<br>    <br>- 不设置该参数：不进一步识别。<br>    <br><br>通过 HTTP 调用时请放入请求头：`-H "X-DashScope-DataInspection: {\"input\": \"cip\", \"output\": \"cip\"}"`；<br><br>通过 Python SDK 调用时请通过`headers`配置：`headers={'X-DashScope-DataInspection': '{"input":"cip","output":"cip"}'}`。<br><br>详细使用方法请参见[内容安全](https://help.aliyun.com/zh/model-studio/content-security)。<br><br>> 不支持通过 Java SDK 设置。<br><br>> 不适用于 Qwen-VL、Qwen-Audio 系列模型。||

|   |   |
|---|---|
|### chat响应对象（流式与非流式输出格式一致）|```json<br>{<br>  "status_code": 200,<br>  "request_id": "902fee3b-f7f0-9a8c-96a1-6b4ea25af114",<br>  "code": "",<br>  "message": "",<br>  "output": {<br>    "text": null,<br>    "finish_reason": null,<br>    "choices": [<br>      {<br>        "finish_reason": "stop",<br>        "message": {<br>          "role": "assistant",<br>          "content": "我是阿里云开发的一款超大规模语言模型，我叫通义千问。"<br>        }<br>      }<br>    ]<br>  },<br>  "usage": {<br>    "input_tokens": 22,<br>    "output_tokens": 17,<br>    "total_tokens": 39<br>  }<br>}<br>```|
|**status_code** `_string_`<br><br>本次请求的状态码。200 表示请求成功，否则表示请求失败。<br><br>> Java SDK不会返回该参数。调用失败会抛出异常，异常信息为**status_code**和**message**的内容。|
|**request_id** `_string_`<br><br>本次调用的唯一标识符。<br><br>> Java SDK返回参数为**requestId。**|
|**code** `_string_`<br><br>错误码，调用成功时为空值。<br><br>> 只有Python SDK返回该参数。|
|**output** `_object_`<br><br>调用结果信息。<br><br>**属性**|
|**usage** `_map_`<br><br>本次chat请求使用的Token信息。<br><br>**属性**|


图生文

本文介绍通义千问 API 的输入输出参数。

> 模型介绍、选型建议和使用方法**，**请参考[文本生成](https://help.aliyun.com/zh/model-studio/text-generation)。

您可以通过 OpenAI 兼容或 DashScope 的方式调用通义千问 API。

## OpenAI 兼容

公有云

金融云

使用SDK调用时需配置的base_url：`https://dashscope.aliyuncs.com/compatible-mode/v1`

使用HTTP方式调用时需配置的endpoint：`POST https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions`

> 您需要已[获取API Key](https://help.aliyun.com/zh/model-studio/get-api-key)并[配置API Key到环境变量](https://help.aliyun.com/zh/model-studio/developer-reference/configure-api-key-through-environment-variables)。如果通过OpenAI SDK进行调用，还需要[安装SDK](https://help.aliyun.com/zh/model-studio/install-sdk/)。

|   |   |
|---|---|
|### 请求体|文本输入<br><br>流式输出<br><br>图像输入<br><br>视频输入<br><br>工具调用<br><br>联网搜索<br><br>异步调用<br><br>文档理解<br><br>文字提取<br><br>> 关于大模型分析图像的更多用法，请参见[视觉理解](https://help.aliyun.com/zh/model-studio/vision)。<br><br>Python<br><br>Node.js<br><br>curl<br><br>```python<br>import os<br>from openai import OpenAI<br><br>client = OpenAI(<br>    # 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",<br>    api_key=os.getenv("DASHSCOPE_API_KEY"),<br>    base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",<br>)<br>completion = client.chat.completions.create(<br>    model="qwen-vl-plus",  # 此处以qwen-vl-plus为例，可按需更换模型名称。模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models<br>    messages=[{"role": "user","content": [<br>            {"type": "image_url",<br>             "image_url": {"url": "https://dashscope.oss-cn-beijing.aliyuncs.com/images/dog_and_girl.jpeg"}},<br>            {"type": "text", "text": "这是什么"},<br>            ]}]<br>    )<br>print(completion.model_dump_json())<br>```|
|**model** `_string_` **（必选）**<br><br>模型名称。<br><br>支持的模型：通义千问大语言模型（商业版、开源版、Qwen-Long）、通义千问VL、通义千问Omni、数学模型、代码模型。<br><br>> 通义千问Audio暂不支持OpenAI兼容模式，仅支持[DashScope](https://help.aliyun.com/zh/model-studio/use-qwen-by-calling-api?mode=pure#a9b7b197e2q2v)方式。<br><br>**具体模型名称和计费，请参见**[模型列表](https://help.aliyun.com/zh/model-studio/models#9f8890ce29g5u)。|
|**messages** `_array_` **（必选）**<br><br>由历史对话组成的消息列表。<br><br>**消息类型**<br><br>System Message `_object_` （可选）<br><br>模型的目标或角色。如果设置系统消息，请放在messages列表的第一位。<br><br>**属性**<br><br>> QwQ 模型不建议设置 System Message，QVQ 模型设置System Message不会生效。<br><br>User Message `_object_` **（必选）**<br><br>用户发送给模型的消息。<br><br>**属性**<br><br>Assistant Message `_object_` （可选）<br><br>模型对用户消息的回复。<br><br>**属性**<br><br>Tool Message `_object_` （可选）<br><br>工具的输出信息。<br><br>**属性**|
|**stream** `_boolean_` （可选） 默认值为 `false`<br><br>是否流式输出回复。参数值：<br><br>- `false`：模型生成完所有内容后一次性返回结果。<br>    <br>- `true`：边生成边输出，即每生成一部分内容就立即输出一个片段（chunk）。您需要实时地逐个读取这些片段以获得完整的结果。<br>    <br><br>> Qwen3商业版（思考模式）、Qwen3开源版、QwQ、QVQ只支持流式输出。|
|**stream_options** `_object_` （可选）<br><br>当启用流式输出时，可通过将本参数设置为`{"include_usage": true}`，在输出的最后一行显示所使用的Token数。<br><br>> 如果设置为false，则最后一行不显示使用的Token数。<br><br>本参数仅在设置stream为true时生效。|
|**modalities** `array` （可选）默认值为`["text"]`<br><br>输出数据的模态，仅支持 [Qwen-Omni](https://help.aliyun.com/zh/model-studio/qwen-omni) 模型指定。可选值：<br><br>- `["text","audio"]`：输出文本与音频；<br>    <br>- `["text"]`：输出文本。|
|**audio** `_object_` （可选）<br><br>输出音频的音色与格式，仅支持 [Qwen-Omni](https://help.aliyun.com/zh/model-studio/qwen-omni) 模型，且`modalities`参数需要包含`"audio"`。<br><br>**属性**|
|**temperature** `_float_` （可选）<br><br>采样温度，控制模型生成文本的多样性。<br><br>temperature越高，生成的文本更多样，反之，生成的文本更确定。<br><br>取值范围： [0, 2)<br><br>由于temperature与top_p均可以控制生成文本的多样性，因此建议您只设置其中一个值。更多说明，请参见[Temperature 和 top_p](https://help.aliyun.com/zh/model-studio/text-generation#ad7b336bec5fw)。<br><br>**temperature默认值**<br><br>> 不建议修改QVQ模型的默认temperature值 。|
|**top_p** `_float_` （可选）<br><br>核采样的概率阈值，控制模型生成文本的多样性。<br><br>top_p越高，生成的文本更多样。反之，生成的文本更确定。<br><br>取值范围：（0,1.0]<br><br>由于temperature与top_p均可以控制生成文本的多样性，因此建议您只设置其中一个值。更多说明，请参见[Temperature 和 top_p](https://help.aliyun.com/zh/model-studio/text-generation#ad7b336bec5fw)。<br><br>**top_p默认值**<br><br>> 不建议修改QVQ模型的默认 top_p 值。|
|**top_k** `_integer_` （可选）<br><br>生成过程中采样候选集的大小。例如，取值为50时，仅将单次生成中得分最高的50个Token组成随机采样的候选集。取值越大，生成的随机性越高；取值越小，生成的确定性越高。取值为None或当top_k大于100时，表示不启用top_k策略，此时仅有top_p策略生效。<br><br>取值需要大于或等于0。<br><br>**top_k默认值**<br><br>> 通过 Python SDK调用时，请将 **top_k** 放入 **extra_body** 对象中，配置方式为：extra_body={"top_k":xxx}。<br><br>> 不建议修改QVQ模型的默认 top_k 值。|
|**presence_penalty** `_float_` （可选）<br><br>控制模型生成文本时的内容重复度。<br><br>取值范围：[-2.0, 2.0]。正数会减少重复度，负数会增加重复度。<br><br>适用场景：<br><br>较高的presence_penalty适用于要求多样性、趣味性或创造性的场景，如创意写作或头脑风暴。<br><br>较低的presence_penalty适用于要求一致性或专业术语的场景，如技术文档或其他正式文档。<br><br>**presence_penalty默认值**<br><br>**原理介绍**<br><br>**示例**<br><br>> 使用qwen-vl-plus、qwen-vl-plus-2025-01-25模型进行文字提取时，建议设置presence_penalty为1.5。<br><br>> 不建议修改QVQ模型的默认presence_penalty值。|
|**response_format** `_object_` （可选） 默认值为`{"type": "text"}`<br><br>返回内容的格式。可选值：`{"type": "text"}`或`{"type": "json_object"}`。设置为`{"type": "json_object"}`时会输出标准格式的JSON字符串。使用方法请参见：[结构化输出](https://help.aliyun.com/zh/model-studio/json-mode)。<br><br>> 如果指定该参数为`{"type": "json_object"}`，您需要在System Message或User Message中指引模型输出JSON格式，如：“请按照json格式输出。”<br><br>支持的模型|
|**max_tokens** `_integer_` （可选）<br><br>本次请求返回的最大 Token 数。<br><br>> `max_tokens` 的设置不会影响大模型的生成过程，如果模型生成的 Token 数超过`max_tokens`，本次请求会返回截断后的内容。<br><br>默认值和最大值都是模型的最大输出长度。关于各模型的最大输出长度，请参见[模型列表](https://help.aliyun.com/zh/model-studio/models#9f8890ce29g5u)。<br><br>max_tokens参数适用于需要限制字数（如生成摘要、关键词）、控制成本或减少响应时间的场景。<br><br>> 对于qwen-vl-ocr-2025-04-13、qwen-vl-ocr-latest模型，max_tokens默认值为2048，最大值为8192。<br><br>> 对于 QwQ、QVQ 与开启思考模式的 Qwen3 模型，`max_tokens`会限制回复内容的长度，不限制深度思考内容的长度。|
|**n** `_integer_` （可选） 默认值为1<br><br>生成响应的个数，取值范围是`1-4`。对于需要生成多个响应的场景（如创意写作、广告文案等），可以设置较大的 n 值。<br><br>> 当前仅支持 qwen-plus 与 [Qwen3（非思考模式）](https://help.aliyun.com/zh/model-studio/deep-thinking#be9890136awsc) 模型，且在传入 tools 参数时固定为1。<br><br>> 设置较大的 n 值不会增加输入 Token 消耗，会增加输出 Token 的消耗。|
|**enable_thinking** `_boolean_` （可选）<br><br>是否开启思考模式，适用于 Qwen3 模型。<br><br>Qwen3 商业版模型默认值为 False，Qwen3 开源版模型默认值为 True。<br><br>> 通过 Python SDK 调用时，请通过`extra_body`配置。配置方式为：`extra_body={"enable_thinking": xxx}`。|
|**thinking_budget** `_integer_` （可选）<br><br>思考过程的最大长度，只在`enable_thinking`为`true`时生效。适用于 Qwen3 的商业版与开源版模型。详情请参见[限制思考长度](https://help.aliyun.com/zh/model-studio/deep-thinking#e7c0002fe4meu)。<br><br>> 通过 Python SDK 调用时，请通过`extra_body`配置。配置方式为：`extra_body={"thinking_budget": xxx}`。|
|**seed** `_integer_` （可选）<br><br>设置seed参数会使文本生成过程更具有确定性，通常用于使模型每次运行的结果一致。<br><br>在每次模型调用时传入相同的seed值（由您指定），并保持其他参数不变，模型将尽可能返回相同的结果。<br><br>取值范围：0到231−1。<br><br>**seed默认值**|
|**stop** `_string 或 array_` （可选）<br><br>使用stop参数后，当模型生成的文本即将包含指定的字符串或token_id时，将自动停止生成。<br><br>您可以在stop参数中传入敏感词来控制模型的输出。<br><br>> stop为array类型时，不可以将token_id和字符串同时作为元素输入，比如不可以指定stop为`["你好",104307]`。|
|**tools** `_array_` （可选）<br><br>可供模型调用的工具数组，可以包含一个或多个工具对象。一次Function Calling流程模型会从中选择一个工具（开启[parallel_tool_calls](https://help.aliyun.com/zh/model-studio/use-qwen-by-calling-api?mode=pure#df816f8ec85ry)可以选择多个工具）。<br><br>> 目前不支持通义千问VL/Audio，也不建议用于数学和代码模型。<br><br>**属性**|
|**tool_choice** `_string 或 object_` （可选）默认值为 `"auto"`<br><br>如果您希望对于某一类问题，大模型能够采取制定好的工具选择策略（如强制使用某个工具、强制使用至少一个工具、强制不使用工具等），可以通过修改`tool_choice`参数来强制指定工具调用的策略。可选值：<br><br>- `"auto"`<br>    <br>    表示由大模型进行工具策略的选择。<br>    <br>- `"none"`<br>    <br>    如果您希望无论输入什么问题，Function Calling 都不会进行工具调用，可以设定`tool_choice`参数为`"none"`；<br>    <br>- `{"type": "function", "function": {"name": "the_function_to_call"}}`<br>    <br>    如果您希望对于某一类问题，Function Calling 能够强制调用某个工具，可以设定`tool_choice`参数为`{"type": "function", "function": {"name": "the_function_to_call"}}`，其中`the_function_to_call`是您指定的工具函数名称。|
|**parallel_tool_calls** `_boolean_` （可选）默认值为 `false`<br><br>是否开启并行工具调用。参数为`true`时开启，为`false`时不开启。并行工具调用详情请参见：[并行工具调用](https://help.aliyun.com/zh/model-studio/qwen-function-calling#cb6b5c484bt4x)。|
|**translation_options** `_object_` （可选）<br><br>当您使用[翻译模型](https://help.aliyun.com/zh/model-studio/machine-translation)时需要配置的翻译参数。<br><br>**属性**<br><br>> 若您通过Python SDK调用，请通过extra_body配置。配置方式为：`extra_body={"translation_options": xxx}`。|
|**enable_search** `_boolean_` （可选）<br><br>模型在生成文本时是否使用互联网搜索结果进行参考。取值如下：<br><br>- true：启用互联网搜索，模型会将搜索结果作为文本生成过程中的参考信息，但模型会基于其内部逻辑判断是否使用互联网搜索结果。<br>    <br>    > 如果模型没有搜索互联网，建议优化Prompt，或设置`search_options`中的`forced_search`参数开启强制搜索。<br>    <br>- false（默认）：关闭互联网搜索。<br>    <br><br>> 启用互联网搜索功能可能会增加 Token 的消耗。<br><br>> 若您通过 Python SDK调用，请通过`extra_body`配置。配置方式为：`extra_body={"enable_search": True}`。<br><br>**支持的模型**|
|**search_options** `_object_` （可选）<br><br>联网搜索的策略。仅当`enable_search`为`true`时生效。<br><br>**属性**<br><br>> 若您通过 Python SDK调用，请通过`extra_body`配置。配置方式为：`extra_body={"search_options": xxx}`。||
|**X-DashScope-DataInspection** `_string_` （可选）<br><br>在通义千问 API 的内容安全能力基础上，是否进一步识别输入输出内容的违规信息。取值如下：<br><br>- `'{"input":"cip","output":"cip"}'`：进一步识别；<br>    <br>- 不设置该参数：不进一步识别。<br>    <br><br>通过 HTTP 调用时请放入请求头：`-H "X-DashScope-DataInspection: {\"input\": \"cip\", \"output\": \"cip\"}"`；<br><br>通过 Python SDK 调用时请通过`extra_headers`配置：`extra_headers={'X-DashScope-DataInspection': '{"input":"cip","output":"cip"}'}`。<br><br>详细使用方法请参见[内容安全](https://help.aliyun.com/zh/model-studio/content-security)。<br><br>> 不支持通过 Node.js SDK设置。<br><br>> 不适用于 Qwen-VL 系列模型。||

|   |   |
|---|---|
|### chat响应对象（非流式输出）|```json<br>{<br>    "choices": [<br>        {<br>            "message": {<br>                "role": "assistant",<br>                "content": "我是阿里云开发的一款超大规模语言模型，我叫通义千问。"<br>            },<br>            "finish_reason": "stop",<br>            "index": 0,<br>            "logprobs": null<br>        }<br>    ],<br>    "object": "chat.completion",<br>    "usage": {<br>        "prompt_tokens": 3019,<br>        "completion_tokens": 104,<br>        "total_tokens": 3123,<br>        "prompt_tokens_details": {<br>            "cached_tokens": 2048<br>        }<br>    },<br>    "created": 1735120033,<br>    "system_fingerprint": null,<br>    "model": "qwen-plus",<br>    "id": "chatcmpl-6ada9ed2-7f33-9de2-8bb0-78bd4035025a"<br>}<br>```|
|**id** `_string_`<br><br>本次调用的唯一标识符。|
|**choices** `_array_`<br><br>模型生成内容的数组，可以包含一个或多个choices对象。<br><br>**属性**|
|**created** `_integer_`<br><br>本次chat请求被创建时的时间戳。|
|**model** `_string_`<br><br>本次chat请求使用的模型名称。|
|**object** `_string_`<br><br>始终为`chat.completion`。|
|**service_tier** `_string_`<br><br>该参数当前固定为`null`。|
|**system_fingerprint** `_string_`<br><br>该参数当前固定为`null`。|
|**usage** `_object_`<br><br>本次chat请求使用的 Token 信息。<br><br>**属性**|

|   |   |
|---|---|
|### chat响应chunk对象（流式输出）|```json<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"","function_call":null,"refusal":null,"role":"assistant","tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"我是","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"来自","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"阿里","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"云的超大规模","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"语言模型，我","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"叫通义千","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"问。","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":"stop","index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}<br>{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":{"completion_tokens":17,"prompt_tokens":22,"total_tokens":39,"completion_tokens_details":null,"prompt_tokens_details":{"audio_tokens":null,"cached_tokens":0}}}<br>```|
|**id** `_string_`<br><br>本次调用的唯一标识符。每个chunk对象有相同的 id。|
|**choices** `_array_`<br><br>模型生成内容的数组，可包含一个或多个choices对象。如果设置`include_usage`参数为`true`，则最后一个chunk为空。<br><br>**属性**|
|**created** `_integer_`<br><br>本次chat请求被创建时的时间戳。每个chunk对象有相同的时间戳。|
|**model** `_string_`<br><br>本次chat请求使用的模型名称。|
|**object** `_string_`<br><br>始终为`chat.completion.chunk`。|
|**service_tier** `_string_`<br><br>该参数当前固定为`null`。|
|**system_fingerprint**`_string_`<br><br>该参数当前固定为`null`。|
|**usage** `_object_`<br><br>本次chat请求使用的Token信息。只在`include_usage`为`true`时，在最后一个chunk显示。<br><br>**属性**|

## DashScope

公有云

金融云

**通过HTTP调用时需配置的endpoint：**

使用通义千问大语言模型：`POST https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation`

使用通义千问VL或通义千问Audio模型：`POST https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation`

> 您需要已[获取API Key](https://help.aliyun.com/zh/model-studio/get-api-key)并[配置API Key到环境变量](https://help.aliyun.com/zh/model-studio/developer-reference/configure-api-key-through-environment-variables)。如果通过DashScope SDK进行调用，还需要[安装DashScope SDK](https://help.aliyun.com/zh/model-studio/install-sdk/#f3e80b21069aa)。

|   |   |
|---|---|
|### 请求体|文本输入<br><br>流式输出<br><br>图像输入<br><br>视频输入<br><br>音频输入<br><br>联网搜索<br><br>工具调用<br><br>异步调用<br><br>文字提取<br><br>> 此处以单轮对话作为示例，您也可以进行[多轮对话](https://help.aliyun.com/zh/model-studio/multi-round-conversation)。<br><br>Python<br><br>Java<br><br>PHP（HTTP）<br><br>Node.js（HTTP）<br><br>C#（HTTP）<br><br>Go（HTTP）<br><br>curl<br><br>```python<br>import os<br>import dashscope<br><br>messages = [<br>    {'role': 'system', 'content': 'You are a helpful assistant.'},<br>    {'role': 'user', 'content': '你是谁？'}<br>    ]<br>response = dashscope.Generation.call(<br>    # 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",<br>    api_key=os.getenv('DASHSCOPE_API_KEY'),<br>    model="qwen-plus", # 此处以qwen-plus为例，可按需更换模型名称。模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models<br>    messages=messages,<br>    result_format='message'<br>    )<br>print(response)<br>```|
|**model** `_string_` **（必选）**<br><br>模型名称。<br><br>支持的模型：通义千问大语言模型（商业版、开源版、Qwen-Long）、通义千问VL、通义千问Audio、数学模型、代码模型<br><br>**具体模型名称和计费，请参见**[模型列表](https://help.aliyun.com/zh/model-studio/models#9f8890ce29g5u)。|
|**messages** `_array_` **（必选）**<br><br>由历史对话组成的消息列表。<br><br>> 通过HTTP调用时，请将**messages** 放入 **input** 对象中。<br><br>**消息类型**|
|**temperature** `_float_` （可选）<br><br>采样温度，控制模型生成文本的多样性。<br><br>temperature越高，生成的文本更多样，反之，生成的文本更确定。<br><br>取值范围： [0, 2)<br><br>**temperature默认值**<br><br>> 通过HTTP调用时，请将 **temperature** 放入 **parameters** 对象中。<br><br>> 不建议修改QVQ模型的默认 temperature 值。|
|**top_p** `_float_` （可选）<br><br>核采样的概率阈值，控制模型生成文本的多样性。<br><br>top_p越高，生成的文本更多样。反之，生成的文本更确定。<br><br>取值范围：（0,1.0]。<br><br>**top_p默认值**<br><br>> Java SDK中为**topP**_。_通过HTTP调用时，请将 **top_p** 放入 **parameters** 对象中。<br><br>> 不建议修改QVQ模型的默认 top_p 值。|
|**top_k** `_integer_` （可选）<br><br>生成过程中采样候选集的大小。例如，取值为50时，仅将单次生成中得分最高的50个Token组成随机采样的候选集。取值越大，生成的随机性越高；取值越小，生成的确定性越高。取值为None或当top_k大于100时，表示不启用top_k策略，此时仅有top_p策略生效。<br><br>取值需要大于或等于0。<br><br>**top_k默认值**<br><br>> Java SDK中为**topK**_。_通过HTTP调用时，请将 **top_k** 放入 **parameters** 对象中。<br><br>> 不建议修改QVQ模型的默认 top_k 值。|
|**enable_thinking** `_boolean_` （可选）<br><br>是否开启思考模式，适用于 Qwen3 商业版与开源版模型。<br><br>Qwen3 开源版默认值为 True，Qwen3 商业版模型默认值为 False。<br><br>> Java SDK 为enableThinking；通过HTTP调用时，请将 **enable_thinking** 放入 **parameters** 对象中。|
|**thinking_budget** `_integer_` （可选）<br><br>思考过程的最大长度，在`enable_thinking`为`true`时生效，适用于qwen-plus-2025-04-28、qwen-plus-latest、qwen-turbo-2025-04-28、qwen-turbo-latest 与 Qwen3 全系模型。详情请参见[限制思考长度](https://help.aliyun.com/zh/model-studio/deep-thinking#e7c0002fe4meu)。|
|**repetition_penalty** `_float_` （可选）<br><br>模型生成时连续序列中的重复度。提高repetition_penalty时可以降低模型生成的重复度，1.0表示不做惩罚。没有严格的取值范围，只要大于0即可。<br><br>**repetition_penalty默认值**<br><br>> Java SDK中为**repetitionPenalty**_。_通过HTTP调用时，请将 **repetition_penalty** 放入 **parameters** 对象中。<br><br>> 使用qwen-vl-plus、qwen-vl-plus_2025-01-25模型进行文字提取时，建议设置repetition_penalty为1.0。<br><br>> 对于qwen-vl-ocr模型，repetition_penalty的默认值为1.05，该参数对模型效果影响较大，请勿随意修改。<br><br>> 不建议修改QVQ模型的默认 repetition_penalty 值。|
|**presence_penalty** `_float_` （可选）<br><br>控制模型生成文本时的内容重复度。<br><br>取值范围：[-2.0, 2.0]。正数会减少重复度，负数会增加重复度。<br><br>适用场景：<br><br>较高的presence_penalty适用于要求多样性、趣味性或创造性的场景，如创意写作或头脑风暴。<br><br>较低的presence_penalty适用于要求一致性或专业术语的场景，如技术文档或其他正式文档。<br><br>**presence_penalty默认值**<br><br>**原理介绍**<br><br>**示例**<br><br>> 使用qwen-vl-plus、qwen-vl-plus-2025-01-25模型进行文字提取时，建议设置presence_penalty为1.5。<br><br>> 不建议修改QVQ模型的默认presence_penalty值。<br><br>> Java SDK不支持设置该参数_。_通过HTTP调用时，请将 **presence_penalty** 放入 **parameters** 对象中。|
|**vl_high_resolution_images** `_boolean_` （可选）默认值为 false<br><br>是否提高输入图片的默认Token上限。输入图片的默认Token上限为1280，配置为true时输入图片的Token上限为16384。<br><br>**支持的模型**<br><br>> Java SDK不支持设置该参数_。_通过HTTP调用时，请将 **vl_high_resolution_images** 放入 **parameters** 对象中。|
|**ocr_options** `_object_` （可选）<br><br>当您使用通义千问OCR模型执行内置任务时需要配置的参数。<br><br>**属性**<br><br>> 设置该参数需保证DashScope Python SDK 最低版本为1.22.2， Java SDK 最低版本为2.18.4。<br><br>> 通过HTTP调用时，请将 **ocr_options** 放入 **parameters** 对象中。|
|**max_tokens** `_integer_` （可选）<br><br>本次请求返回的最大 Token 数。<br><br>> `max_tokens` 的设置不会影响大模型的生成过程，如果模型生成的 Token 数超过`max_tokens`，本次请求会返回截断后的内容。<br><br>默认值和最大值都是模型的最大输出长度。关于各模型的最大输出长度，请参见[模型列表](https://help.aliyun.com/zh/model-studio/models#9f8890ce29g5u)。<br><br>max_tokens参数适用于需要限制字数（如生成摘要、关键词）、控制成本或减少响应时间的场景。<br><br>> 对于qwen-vl-ocr-2025-04-13、qwen-vl-ocr-latest模型，max_tokens默认值为2048，最大值为8192。<br><br>> 对于 QwQ、QVQ 与开启思考模式的 Qwen3 模型，`max_tokens`会限制回复内容的长度，不限制深度思考内容的长度。<br><br>> 对于qwen-vl-ocr-2025-04-13、qwen-vl-ocr-latest模型，max_tokens默认值为2048，最大值为8192。<br><br>> Java SDK中为**maxTokens**（模型为通义千问VL/OCR/Audio/ASR时，Java SDK中为**maxLength，**在 2.18.4 版本之后支持也设置为 maxTokens）_。_通过HTTP调用时，请将 **max_tokens** 放入 **parameters** 对象中。|
|**seed** `_integer_` （可选）<br><br>设置seed参数会使文本生成过程更具有确定性，通常用于使模型每次运行的结果一致。<br><br>在每次模型调用时传入相同的seed值（由您指定），并保持其他参数不变，模型将尽可能返回相同的结果。<br><br>取值范围：0到231−1。<br><br>**seed默认值**<br><br>> 通过HTTP调用时，请将 **seed** 放入 **parameters** 对象中。|
|**stream** `_boolean_` （可选）<br><br>是否流式输出回复。参数值：<br><br>- false（默认值）：模型生成完所有内容后一次性返回结果。<br>    <br>- true：边生成边输出，即每生成一部分内容就立即输出一个片段（chunk）。<br>    <br><br>> 该参数仅支持Python SDK。通过Java SDK实现流式输出请通过`streamCall`接口调用；通过HTTP实现流式输出请在Header中指定`X-DashScope-SSE`为`enable`。<br><br>> Qwen3商业版（思考模式）、Qwen3开源版、QwQ、QVQ只支持流式输出。|
|**incremental_output** `_boolean_` （可选）默认为`false`（[Qwen3 开源版](https://help.aliyun.com/zh/model-studio/models#9d516d17965af)、[QwQ](https://help.aliyun.com/zh/model-studio/deep-thinking) 、[QVQ](https://help.aliyun.com/zh/model-studio/qvq)模型默认值为 `true`）<br><br>在流式输出模式下是否开启增量输出。参数值：<br><br>- false：每次输出为当前已经生成的整个序列，最后一次输出为生成的完整结果。<br>    <br>    ```plaintext<br>    I<br>    I like<br>    I like apple<br>    I like apple.<br>    ```<br>    <br>- true：增量输出，即后续输出内容不包含已输出的内容。您需要实时地逐个读取这些片段以获得完整的结果。<br>    <br>    ```plaintext<br>    I<br>    like<br>    apple<br>    .<br>    ```<br>    <br><br>> Java SDK中为**incrementalOutput**_。_通过HTTP调用时，请将 **incremental_output** 放入 **parameters** 对象中。<br><br>> QwQ 模型与思考模式下的 Qwen3 模型只支持设置为 `true`。由于 Qwen3 商业版模型默认值为`false`，您需要在思考模式下手动设置为 `true`。<br><br>> Qwen3 开源版模型不支持设置为 `false`。|
|**response_format** `_object_` （可选） 默认值为`{"type": "text"}`<br><br>返回内容的格式。可选值：`{"type": "text"}`或`{"type": "json_object"}`。设置为`{"type": "json_object"}`时会输出标准格式的JSON字符串。使用方法请参见：[结构化输出](https://help.aliyun.com/zh/model-studio/json-mode)。<br><br>> 如果指定该参数为`{"type": "json_object"}`，您需要在 System Message 或 User Message 中指引模型输出 JSON 格式，如：“请按照json格式输出。”<br><br>> 不支持通过 Java SDK 设置该参数。通过HTTP调用时，请将 **response_format** 放入 **parameters** 对象中。<br><br>支持的模型|
|**result_format** `_string_` （可选） 默认为`"text"`（[QwQ](https://help.aliyun.com/zh/model-studio/deep-thinking) 模型、Qwen3 开源模型与 Qwen-Long 模型默认值为 `"message"`）<br><br>返回数据的格式。推荐您优先设置为`"message"`，可以更方便地进行[多轮对话](https://help.aliyun.com/zh/model-studio/multi-round-conversation)。<br><br>> 平台后续将统一将默认值调整为"message"。<br><br>> Java SDK中为**resultFormat**_。_通过HTTP调用时，请将 **result_format** 放入 **parameters** 对象中。<br><br>> 模型为通义千问VL/QVQ/OCR/Audio/ASR时，设置“`text`”不生效。<br><br>> 思考模式下的 Qwen3 模型只能设置为`"message"`，由于 Qwen3 商业版模型默认值为"text"，您需要将其设置为`"message"`。<br><br>> 如果您使用 Java SDK 调用Qwen3 开源模型，并且传入了 "text"，依然会以 "message"格式进行返回。|
|**stop** `_string 或 array_` （可选）<br><br>使用stop参数后，当模型生成的文本即将包含指定的字符串或token_id时，将自动停止生成。<br><br>您可以在stop参数中传入敏感词来控制模型的输出。<br><br>> stop为array类型时，不可以将token_id和字符串同时作为元素输入，比如不可以指定stop为`["你好",104307]`。|
|**tools** `_array_` （可选）<br><br>可供模型调用的工具数组，可以包含一个或多个工具对象。一次 Function Calling 流程模型会从中选择其中一个工具（开启[parallel_tool_calls](https://help.aliyun.com/zh/model-studio/use-qwen-by-calling-api?mode=pure#5398ced61euxr)参数可能选择多个工具）。使用 tools 时需要同时指定`result_format`参数为`"message"`。无论是发起 Function Calling，还是向模型提交工具函数的执行结果，均需设置tools参数。<br><br>> 目前不支持通义千问VL/Audio，也不建议用于数学和代码模型。<br><br>**属性**<br><br>> 通过HTTP调用时，请将 **tools** 放入 **parameters** JSON 对象中。暂时不支持qwen-vl与qwen-audio系列模型。|
|**tool_choice** `_string 或 object_` （可选）<br><br>在使用tools参数时，用于控制模型调用指定工具。有三种取值：<br><br>- `"none"`表示不调用工具。tools参数为空时，默认值为`"none"`。<br>    <br>- `"auto"`表示由模型判断是否调用工具，可能调用也可能不调用。tools参数不为空时，默认值为`"auto"`。<br>    <br>- object结构可以指定模型调用的工具。例如`tool_choice={"type": "function", "function": {"name": "user_function"}}`。<br>    <br>    - type只支持指定为`"function"`。<br>        <br>    - function<br>        <br>        - name表示期望被调用的工具名称，例如`"get_current_time"`。<br>            <br><br>> Java SDK中为**toolChoice**_。_通过HTTP调用时，请将 **tool_choice** 放入 **parameters** 对象中。|
|**parallel_tool_calls** `_boolean_` （可选）默认值为 `false`<br><br>是否开启并行工具调用。参数为`true`时开启，为`false`时不开启。并行工具调用详情请参见：[并行工具调用](https://help.aliyun.com/zh/model-studio/qwen-function-calling#cb6b5c484bt4x)。|
|**translation_options** `_object_` （可选）<br><br>当您使用[翻译模型](https://help.aliyun.com/zh/model-studio/machine-translation)时需要配置的翻译参数。<br><br>**属性**<br><br>> Java SDK 暂不支持配置该参数。通过HTTP调用时，请将 **translation_options** 放入 **parameters** 对象中。|
|**enable_search** `_boolean_` （可选）<br><br>模型在生成文本时是否使用互联网搜索结果进行参考。取值如下：<br><br>- true：启用互联网搜索，模型会将搜索结果作为文本生成过程中的参考信息，但模型会基于其内部逻辑判断是否使用互联网搜索结果。<br>    <br>    > 如果模型没有搜索互联网，建议优化Prompt，或设置`search_options`中的`forced_search`参数开启强制搜索。<br>    <br>- false（默认）：关闭互联网搜索。<br>    <br><br>**支持的模型**<br><br>> Java SDK中为**enableSearch**_。_通过HTTP调用时，请将 **enable_search** 放入 **parameters** 对象中。<br><br>> 启用互联网搜索功能可能会增加 Token 的消耗。|
|**search_options** `_object_` （可选）<br><br>联网搜索的策略。仅当`enable_search`为`true`时生效。<br><br>> 通过HTTP调用时，请将 **search_options** 放入 **parameters** 对象中。Java SDK中为searchOptions。<br><br>**属性**|
|**X-DashScope-DataInspection** `_string_` （可选）<br><br>在通义千问 API 的内容安全能力基础上，是否进一步识别输入输出内容的违规信息。取值如下：<br><br>- `'{"input":"cip","output":"cip"}'`：进一步识别；<br>    <br>- 不设置该参数：不进一步识别。<br>    <br><br>通过 HTTP 调用时请放入请求头：`-H "X-DashScope-DataInspection: {\"input\": \"cip\", \"output\": \"cip\"}"`；<br><br>通过 Python SDK 调用时请通过`headers`配置：`headers={'X-DashScope-DataInspection': '{"input":"cip","output":"cip"}'}`。<br><br>详细使用方法请参见[内容安全](https://help.aliyun.com/zh/model-studio/content-security)。<br><br>> 不支持通过 Java SDK 设置。<br><br>> 不适用于 Qwen-VL、Qwen-Audio 系列模型。||

|                                                                                                                                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| --------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ### chat响应对象（流式与非流式输出格式一致）                                                                                                              | ```json<br>{<br>  "status_code": 200,<br>  "request_id": "902fee3b-f7f0-9a8c-96a1-6b4ea25af114",<br>  "code": "",<br>  "message": "",<br>  "output": {<br>    "text": null,<br>    "finish_reason": null,<br>    "choices": [<br>      {<br>        "finish_reason": "stop",<br>        "message": {<br>          "role": "assistant",<br>          "content": "我是阿里云开发的一款超大规模语言模型，我叫通义千问。"<br>        }<br>      }<br>    ]<br>  },<br>  "usage": {<br>    "input_tokens": 22,<br>    "output_tokens": 17,<br>    "total_tokens": 39<br>  }<br>}<br>``` |
| **status_code** `_string_`<br><br>本次请求的状态码。200 表示请求成功，否则表示请求失败。<br><br>> Java SDK不会返回该参数。调用失败会抛出异常，异常信息为**status_code**和**message**的内容。 |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| **request_id** `_string_`<br><br>本次调用的唯一标识符。<br><br>> Java SDK返回参数为**requestId。**                                                       |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| **code** `_string_`<br><br>错误码，调用成功时为空值。<br><br>> 只有Python SDK返回该参数。                                                                    |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| **output** `_object_`<br><br>调用结果信息。<br><br>**属性**                                                                                      |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| **usage** `_map_`<br><br>本次chat请求使用的Token信息。<br><br>**属性**                                                                              |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|                                                                                                                                         |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |


import osfrom openai import OpenAI

  

  

client = OpenAI(

# 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",

)

  

completion = client.chat.completions.create(

# 模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models

model="qwen-plus",

messages=[

{"role": "system", "content": "You are a helpful assistant."},

{"role": "user", "content": "你是谁？"},

],

# Qwen3模型通过enable_thinking参数控制思考过程（开源版默认True，商业版默认False）

# 使用Qwen3开源版模型时，若未启用流式输出，请将下行取消注释，否则会报错

# extra_body={"enable_thinking": False},

)print(completion.model_dump_json())

  

  

import osfrom openai import OpenAI

  

client = OpenAI(

# 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",

)

completion = client.chat.completions.create(

model="qwen-plus", # 此处以qwen-plus为例，可按需更换模型名称。模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models

messages=[{'role': 'system', 'content': 'You are a helpful assistant.'},

{'role': 'user', 'content': '你是谁？'}],

stream=True,

stream_options={"include_usage": True}

)for chunk in completion:

print(chunk.model_dump_json())

  

本文介绍通义千问 API 的输入输出参数。

模型介绍、选型建议和使用方法，请参考文本生成。

您可以通过 OpenAI 兼容或 DashScope 的方式调用通义千问 API。

OpenAI 兼容

公有云金融云

  

  

使用SDK调用时需配置的base_url：https://dashscope.aliyuncs.com/compatible-mode/v1

使用HTTP方式调用时需配置的endpoint：POST https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions

您需要已获取API Key并配置API Key到环境变量。如果通过OpenAI SDK进行调用，还需要安装SDK。

  

请求体

文本输入流式输出图像输入视频输入工具调用联网搜索异步调用文档理解文字提取

  

  

此处以单轮对话作为示例，您也可以进行多轮对话。

  

PythonJavaNode.jsGoC#（HTTP）PHP（HTTP）curl

  

  

import osfrom openai import OpenAI

  

  

client = OpenAI(

# 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",

)

  

completion = client.chat.completions.create(

# 模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models

model="qwen-plus",

messages=[

{"role": "system", "content": "You are a helpful assistant."},

{"role": "user", "content": "你是谁？"},

],

# Qwen3模型通过enable_thinking参数控制思考过程（开源版默认True，商业版默认False）

# 使用Qwen3开源版模型时，若未启用流式输出，请将下行取消注释，否则会报错

# extra_body={"enable_thinking": False},

)print(completion.model_dump_json())

model string （必选）

模型名称。

支持的模型：通义千问大语言模型（商业版、开源版、Qwen-Long）、通义千问VL、通义千问Omni、数学模型、代码模型。

通义千问Audio暂不支持OpenAI兼容模式，仅支持DashScope方式。

具体模型名称和计费，请参见模型列表。

messages array （必选）

由历史对话组成的消息列表。

消息类型

  

System Message object （可选）

模型的目标或角色。如果设置系统消息，请放在messages列表的第一位。

属性

  

QwQ 模型不建议设置 System Message，QVQ 模型设置System Message不会生效。

User Message object （必选）

用户发送给模型的消息。

属性

  

Assistant Message object （可选）

模型对用户消息的回复。

属性

  

Tool Message object （可选）

工具的输出信息。

属性

  

stream boolean （可选） 默认值为 false

是否流式输出回复。参数值：

  

false：模型生成完所有内容后一次性返回结果。

true：边生成边输出，即每生成一部分内容就立即输出一个片段（chunk）。您需要实时地逐个读取这些片段以获得完整的结果。

Qwen3商业版（思考模式）、Qwen3开源版、QwQ、QVQ只支持流式输出。

stream_options object （可选）

当启用流式输出时，可通过将本参数设置为{"include_usage": true}，在输出的最后一行显示所使用的Token数。

如果设置为false，则最后一行不显示使用的Token数。

本参数仅在设置stream为true时生效。

modalities array （可选）默认值为["text"]

输出数据的模态，仅支持 Qwen-Omni 模型指定。可选值：

  

["text","audio"]：输出文本与音频；

["text"]：输出文本。

audio object （可选）

输出音频的音色与格式，仅支持 Qwen-Omni 模型，且modalities参数需要包含"audio"。

属性

  

temperature float （可选）

采样温度，控制模型生成文本的多样性。

temperature越高，生成的文本更多样，反之，生成的文本更确定。

取值范围： [0, 2)

由于temperature与top_p均可以控制生成文本的多样性，因此建议您只设置其中一个值。更多说明，请参见Temperature 和 top_p。

temperature默认值

  

不建议修改QVQ模型的默认temperature值 。

top_p float （可选）

核采样的概率阈值，控制模型生成文本的多样性。

top_p越高，生成的文本更多样。反之，生成的文本更确定。

取值范围：（0,1.0]

由于temperature与top_p均可以控制生成文本的多样性，因此建议您只设置其中一个值。更多说明，请参见Temperature 和 top_p。

top_p默认值

  

不建议修改QVQ模型的默认 top_p 值。

top_k integer （可选）

生成过程中采样候选集的大小。例如，取值为50时，仅将单次生成中得分最高的50个Token组成随机采样的候选集。取值越大，生成的随机性越高；取值越小，生成的确定性越高。取值为None或当top_k大于100时，表示不启用top_k策略，此时仅有top_p策略生效。

取值需要大于或等于0。

top_k默认值

  

通过 Python SDK调用时，请将 top_k 放入 extra_body 对象中，配置方式为：extra_body={"top_k":xxx}。

不建议修改QVQ模型的默认 top_k 值。

presence_penalty float （可选）

控制模型生成文本时的内容重复度。

取值范围：[-2.0, 2.0]。正数会减少重复度，负数会增加重复度。

适用场景：

较高的presence_penalty适用于要求多样性、趣味性或创造性的场景，如创意写作或头脑风暴。

较低的presence_penalty适用于要求一致性或专业术语的场景，如技术文档或其他正式文档。

presence_penalty默认值

  

原理介绍

  

示例

  

使用qwen-vl-plus、qwen-vl-plus-2025-01-25模型进行文字提取时，建议设置presence_penalty为1.5。

不建议修改QVQ模型的默认presence_penalty值。

response_format object （可选） 默认值为{"type": "text"}

返回内容的格式。可选值：{"type": "text"}或{"type": "json_object"}。设置为{"type": "json_object"}时会输出标准格式的JSON字符串。使用方法请参见：结构化输出。

如果指定该参数为{"type": "json_object"}，您需要在System Message或User Message中指引模型输出JSON格式，如：“请按照json格式输出。”

支持的模型

  

max_tokens integer （可选）

本次请求返回的最大 Token 数。

max_tokens 的设置不会影响大模型的生成过程，如果模型生成的 Token 数超过max_tokens，本次请求会返回截断后的内容。

默认值和最大值都是模型的最大输出长度。关于各模型的最大输出长度，请参见模型列表。

max_tokens参数适用于需要限制字数（如生成摘要、关键词）、控制成本或减少响应时间的场景。

qwen-vl-ocr-latest、qwen-vl-ocr-2025-04-13模型的max_tokens参数（最大输出长度）默认为 2048，如需提高该参数值（2049~8192范围），请发送邮件至 modelstudio@service.aliyun.com进行申请，并提供以下信息：主账号ID、图像类型（如文档图、电商图、合同等）、模型名称、预计 QPS 和每日请求总数，以及模型输出长度超过2048的请求占比。

对于 QwQ、QVQ 与开启思考模式的 Qwen3 模型，max_tokens会限制回复内容的长度，不限制深度思考内容的长度。

n integer （可选） 默认值为1

生成响应的个数，取值范围是1-4。对于需要生成多个响应的场景（如创意写作、广告文案等），可以设置较大的 n 值。

当前仅支持 qwen-plus 与 Qwen3（非思考模式） 模型，且在传入 tools 参数时固定为1。

设置较大的 n 值不会增加输入 Token 消耗，会增加输出 Token 的消耗。

enable_thinking boolean （可选）

是否开启思考模式，适用于 Qwen3 模型。

Qwen3 商业版模型默认值为 False，Qwen3 开源版模型默认值为 True。

通过 Python SDK 调用时，请通过extra_body配置。配置方式为：extra_body={"enable_thinking": xxx}。

thinking_budget integer （可选）

思考过程的最大长度，只在enable_thinking为true时生效。适用于 Qwen3 的商业版与开源版模型。详情请参见限制思考长度。

通过 Python SDK 调用时，请通过extra_body配置。配置方式为：extra_body={"thinking_budget": xxx}。

seed integer （可选）

设置seed参数会使文本生成过程更具有确定性，通常用于使模型每次运行的结果一致。

在每次模型调用时传入相同的seed值（由您指定），并保持其他参数不变，模型将尽可能返回相同的结果。

取值范围：0到231−1。

seed默认值

  

logprobs boolean （可选）

是否返回输出 Token 的对数概率，可选值：

  

true

返回；

false

不返回。

支持 qwen-plus、qwen-turbo 系列的快照模型（不包含主线模型）与 Qwen3 开源模型。

top_logprobs integer （可选）

指定在每一步生成时，返回模型最大概率的候选 Token 个数。

取值范围：[0,5]

仅当 logprobs 为 true 时生效。

stop string 或 array （可选）

使用stop参数后，当模型生成的文本即将包含指定的字符串或token_id时，将自动停止生成。

您可以在stop参数中传入敏感词来控制模型的输出。

stop为array类型时，不可以将token_id和字符串同时作为元素输入，比如不可以指定stop为["你好",104307]。

tools array （可选）

可供模型调用的工具数组，可以包含一个或多个工具对象。一次Function Calling流程模型会从中选择一个工具（开启parallel_tool_calls可以选择多个工具）。

目前不支持通义千问VL/Audio，也不建议用于数学和代码模型。

属性

  

tool_choice string 或 object （可选）默认值为 "auto"

如果您希望对于某一类问题，大模型能够采取制定好的工具选择策略（如强制使用某个工具、强制不使用工具），可以通过修改tool_choice参数来强制指定工具调用的策略。可选值：

  

"auto"

表示由大模型进行工具策略的选择。

"none"

如果您希望无论输入什么问题，Function Calling 都不会进行工具调用，可以设定tool_choice参数为"none"；

{"type": "function", "function": {"name": "the_function_to_call"}}

如果您希望对于某一类问题，Function Calling 能够强制调用某个工具，可以设定tool_choice参数为{"type": "function", "function": {"name": "the_function_to_call"}}，其中the_function_to_call是您指定的工具函数名称。

parallel_tool_calls boolean （可选）默认值为 false

是否开启并行工具调用。参数为true时开启，为false时不开启。并行工具调用详情请参见：并行工具调用。

translation_options object （可选）

当您使用翻译模型时需要配置的翻译参数。

属性

  

若您通过Python SDK调用，请通过extra_body配置。配置方式为：extra_body={"translation_options": xxx}。

enable_search boolean （可选）

模型在生成文本时是否使用互联网搜索结果进行参考。取值如下：

  

true：启用互联网搜索，模型会将搜索结果作为文本生成过程中的参考信息，但模型会基于其内部逻辑判断是否使用互联网搜索结果。

如果模型没有搜索互联网，建议优化Prompt，或设置search_options中的forced_search参数开启强制搜索。

false（默认）：关闭互联网搜索。

启用互联网搜索功能可能会增加 Token 的消耗。

若您通过 Python SDK调用，请通过extra_body配置。配置方式为：extra_body={"enable_search": True}。

支持的模型

  

search_options object （可选）

联网搜索的策略。仅当enable_search为true时生效。

属性

  

若您通过 Python SDK调用，请通过extra_body配置。配置方式为：extra_body={"search_options": xxx}。

X-DashScope-DataInspection string （可选）

在通义千问 API 的内容安全能力基础上，是否进一步识别输入输出内容的违规信息。取值如下：

  

'{"input":"cip","output":"cip"}'：进一步识别；

不设置该参数：不进一步识别。

通过 HTTP 调用时请放入请求头：-H "X-DashScope-DataInspection: {\"input\": \"cip\", \"output\": \"cip\"}"；

通过 Python SDK 调用时请通过extra_headers配置：extra_headers={'X-DashScope-DataInspection': '{"input":"cip","output":"cip"}'}。

详细使用方法请参见内容安全。

不支持通过 Node.js SDK设置。

不适用于 Qwen-VL 系列模型。

chat响应对象（非流式输出）

{

"choices": [

{

"message": {

"role": "assistant",

"content": "我是阿里云开发的一款超大规模语言模型，我叫通义千问。"

},

"finish_reason": "stop",

"index": 0,

"logprobs": null

}

],

"object": "chat.completion",

"usage": {

"prompt_tokens": 3019,

"completion_tokens": 104,

"total_tokens": 3123,

"prompt_tokens_details": {

"cached_tokens": 2048

}

},

"created": 1735120033,

"system_fingerprint": null,

"model": "qwen-plus",

"id": "chatcmpl-6ada9ed2-7f33-9de2-8bb0-78bd4035025a"}

id string

本次调用的唯一标识符。

choices array

模型生成内容的数组，可以包含一个或多个choices对象。

属性

  

created integer

本次chat请求被创建时的时间戳。

model string

本次chat请求使用的模型名称。

object string

始终为chat.completion。

service_tier string

该参数当前固定为null。

system_fingerprint string

该参数当前固定为null。

usage object

本次chat请求使用的 Token 信息。

属性

  

chat响应chunk对象（流式输出）

{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"","function_call":null,"refusal":null,"role":"assistant","tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"我是","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"来自","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"阿里","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"云的超大规模","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"语言模型，我","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"叫通义千","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"问。","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":null,"index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[{"delta":{"content":"","function_call":null,"refusal":null,"role":null,"tool_calls":null},"finish_reason":"stop","index":0,"logprobs":null}],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":null}{"id":"chatcmpl-e30f5ae7-3063-93c4-90fe-beb5f900bd57","choices":[],"created":1735113344,"model":"qwen-plus","object":"chat.completion.chunk","service_tier":null,"system_fingerprint":null,"usage":{"completion_tokens":17,"prompt_tokens":22,"total_tokens":39,"completion_tokens_details":null,"prompt_tokens_details":{"audio_tokens":null,"cached_tokens":0}}}

id string

本次调用的唯一标识符。每个chunk对象有相同的 id。

choices array

模型生成内容的数组，可包含一个或多个choices对象。如果设置include_usage参数为true，则最后一个chunk为空。

属性

  

created integer

本次chat请求被创建时的时间戳。每个chunk对象有相同的时间戳。

model string

本次chat请求使用的模型名称。

object string

始终为chat.completion.chunk。

service_tier string

该参数当前固定为null。

system_fingerprintstring

该参数当前固定为null。

usage object

本次chat请求使用的Token信息。只在include_usage为true时，在最后一个chunk显示。

属性

  

DashScope

公有云金融云

  

  

通过HTTP调用时需配置的endpoint：

使用通义千问大语言模型：POST https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation

使用通义千问VL或通义千问Audio模型：POST https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation

您需要已获取API Key并配置API Key到环境变量。如果通过DashScope SDK进行调用，还需要安装DashScope SDK。

  

请求体

文本输入流式输出图像输入视频输入音频输入联网搜索工具调用异步调用文字提取

  

  

此处以单轮对话作为示例，您也可以进行多轮对话。

  

PythonJavaPHP（HTTP）Node.js（HTTP）C#（HTTP）Go（HTTP）curl

  

  

import osimport dashscope

  

messages = [

{'role': 'system', 'content': 'You are a helpful assistant.'},

{'role': 'user', 'content': '你是谁？'}

]

response = dashscope.Generation.call(

# 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv('DASHSCOPE_API_KEY'),

model="qwen-plus", # 此处以qwen-plus为例，可按需更换模型名称。模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models

messages=messages,

result_format='message'

)print(response)

model string （必选）

模型名称。

支持的模型：通义千问大语言模型（商业版、开源版、Qwen-Long）、通义千问VL、通义千问Audio、数学模型、代码模型

具体模型名称和计费，请参见模型列表。

messages array （必选）

由历史对话组成的消息列表。

通过HTTP调用时，请将messages 放入 input 对象中。

消息类型

  

temperature float （可选）

采样温度，控制模型生成文本的多样性。

temperature越高，生成的文本更多样，反之，生成的文本更确定。

取值范围： [0, 2)

temperature默认值

  

通过HTTP调用时，请将 temperature 放入 parameters 对象中。

不建议修改QVQ模型的默认 temperature 值。

top_p float （可选）

核采样的概率阈值，控制模型生成文本的多样性。

top_p越高，生成的文本更多样。反之，生成的文本更确定。

取值范围：（0,1.0]。

top_p默认值

  

Java SDK中为topP。通过HTTP调用时，请将 top_p 放入 parameters 对象中。

不建议修改QVQ模型的默认 top_p 值。

top_k integer （可选）

生成过程中采样候选集的大小。例如，取值为50时，仅将单次生成中得分最高的50个Token组成随机采样的候选集。取值越大，生成的随机性越高；取值越小，生成的确定性越高。取值为None或当top_k大于100时，表示不启用top_k策略，此时仅有top_p策略生效。

取值需要大于或等于0。

top_k默认值

  

Java SDK中为topK。通过HTTP调用时，请将 top_k 放入 parameters 对象中。

不建议修改QVQ模型的默认 top_k 值。

enable_thinking boolean （可选）

是否开启思考模式，适用于 Qwen3 商业版与开源版模型。

Qwen3 开源版默认值为 True，Qwen3 商业版模型默认值为 False。

Java SDK 为enableThinking；通过HTTP调用时，请将 enable_thinking 放入 parameters 对象中。

thinking_budget integer （可选）

思考过程的最大长度，在enable_thinking为true时生效，适用于qwen-plus-2025-04-28、qwen-plus-latest、qwen-turbo-2025-04-28、qwen-turbo-latest 与 Qwen3 全系模型。详情请参见限制思考长度。

repetition_penalty float （可选）

模型生成时连续序列中的重复度。提高repetition_penalty时可以降低模型生成的重复度，1.0表示不做惩罚。没有严格的取值范围，只要大于0即可。

repetition_penalty默认值

  

Java SDK中为repetitionPenalty。通过HTTP调用时，请将 repetition_penalty 放入 parameters 对象中。

使用qwen-vl-plus、qwen-vl-plus_2025-01-25模型进行文字提取时，建议设置repetition_penalty为1.0。

对于qwen-vl-ocr模型，repetition_penalty的默认值为1.05，该参数对模型效果影响较大，请勿随意修改。

不建议修改QVQ模型的默认 repetition_penalty 值。

presence_penalty float （可选）

控制模型生成文本时的内容重复度。

取值范围：[-2.0, 2.0]。正数会减少重复度，负数会增加重复度。

适用场景：

较高的presence_penalty适用于要求多样性、趣味性或创造性的场景，如创意写作或头脑风暴。

较低的presence_penalty适用于要求一致性或专业术语的场景，如技术文档或其他正式文档。

presence_penalty默认值

  

原理介绍

  

示例

  

使用qwen-vl-plus、qwen-vl-plus-2025-01-25模型进行文字提取时，建议设置presence_penalty为1.5。

不建议修改QVQ模型的默认presence_penalty值。

Java SDK不支持设置该参数。通过HTTP调用时，请将 presence_penalty 放入 parameters 对象中。

vl_high_resolution_images boolean （可选）默认值为 false

是否提高输入图片的默认Token上限。输入图片的默认Token上限为1280，配置为true时输入图片的Token上限为16384。

支持的模型

  

Java SDK不支持设置该参数。通过HTTP调用时，请将 vl_high_resolution_images 放入 parameters 对象中。

ocr_options object （可选）

当您使用通义千问OCR模型执行内置任务时需要配置的参数。

属性

  

设置该参数需保证DashScope Python SDK 最低版本为1.22.2， Java SDK 最低版本为2.18.4。

通过HTTP调用时，请将 ocr_options 放入 parameters 对象中。

max_tokens integer （可选）

本次请求返回的最大 Token 数。

max_tokens 的设置不会影响大模型的生成过程，如果模型生成的 Token 数超过max_tokens，本次请求会返回截断后的内容。

默认值和最大值都是模型的最大输出长度。关于各模型的最大输出长度，请参见模型列表。

max_tokens参数适用于需要限制字数（如生成摘要、关键词）、控制成本或减少响应时间的场景。

qwen-vl-ocr-latest、qwen-vl-ocr-2025-04-13模型的max_tokens参数（最大输出长度）默认为 2048，如需提高该参数值（2049~8192范围），请发送邮件至 modelstudio@service.aliyun.com进行申请，并提供以下信息：主账号ID、图像类型（如文档图、电商图、合同等）、模型名称、预计 QPS 和每日请求总数，以及模型输出长度超过2048的请求占比。

对于 QwQ、QVQ 与开启思考模式的 Qwen3 模型，max_tokens会限制回复内容的长度，不限制深度思考内容的长度。

Java SDK中为maxTokens（模型为通义千问VL/OCR/Audio/ASR时，Java SDK中为maxLength，在 2.18.4 版本之后支持也设置为 maxTokens）。通过HTTP调用时，请将 max_tokens 放入 parameters 对象中。

seed integer （可选）

设置seed参数会使文本生成过程更具有确定性，通常用于使模型每次运行的结果一致。

在每次模型调用时传入相同的seed值（由您指定），并保持其他参数不变，模型将尽可能返回相同的结果。

取值范围：0到231−1。

seed默认值

  

通过HTTP调用时，请将 seed 放入 parameters 对象中。

stream boolean （可选）

是否流式输出回复。参数值：

  

false（默认值）：模型生成完所有内容后一次性返回结果。

true：边生成边输出，即每生成一部分内容就立即输出一个片段（chunk）。

该参数仅支持Python SDK。通过Java SDK实现流式输出请通过streamCall接口调用；通过HTTP实现流式输出请在Header中指定X-DashScope-SSE为enable。

Qwen3商业版（思考模式）、Qwen3开源版、QwQ、QVQ只支持流式输出。

incremental_output boolean （可选）默认为false（Qwen3 开源版、QwQ 、QVQ模型默认值为 true）

在流式输出模式下是否开启增量输出。参数值：

  

false：每次输出为当前已经生成的整个序列，最后一次输出为生成的完整结果。

  

I

I like

I like apple

I like apple.

true：增量输出，即后续输出内容不包含已输出的内容。您需要实时地逐个读取这些片段以获得完整的结果。

  

I

like

apple

.

Java SDK中为incrementalOutput。通过HTTP调用时，请将 incremental_output 放入 parameters 对象中。

QwQ 模型与思考模式下的 Qwen3 模型只支持设置为 true。由于 Qwen3 商业版模型默认值为false，您需要在思考模式下手动设置为 true。

Qwen3 开源版模型不支持设置为 false。

response_format object （可选） 默认值为{"type": "text"}

返回内容的格式。可选值：{"type": "text"}或{"type": "json_object"}。设置为{"type": "json_object"}时会输出标准格式的JSON字符串。使用方法请参见：结构化输出。

如果指定该参数为{"type": "json_object"}，您需要在 System Message 或 User Message 中指引模型输出 JSON 格式，如：“请按照json格式输出。”

Java SDK 中为 responseFormat。通过HTTP调用时，请将 response_format 放入 parameters 对象中。

支持的模型

  

result_format string （可选） 默认为"text"（QwQ 模型、Qwen3 开源模型与 Qwen-Long 模型默认值为 "message"）

返回数据的格式。推荐您优先设置为"message"，可以更方便地进行多轮对话。

平台后续将统一将默认值调整为"message"。

Java SDK中为resultFormat。通过HTTP调用时，请将 result_format 放入 parameters 对象中。

模型为通义千问VL/QVQ/OCR/Audio/ASR时，设置“text”不生效。

思考模式下的 Qwen3 模型只能设置为"message"，由于 Qwen3 商业版模型默认值为"text"，您需要将其设置为"message"。

如果您使用 Java SDK 调用Qwen3 开源模型，并且传入了 "text"，依然会以 "message"格式进行返回。

logprobs boolean （可选）

是否返回输出 Token 的对数概率，可选值：

  

true

返回；

false

不返回。

支持 qwen-plus、qwen-turbo 系列的快照模型（不包含主线模型）与 Qwen3 开源模型。

top_logprobs integer （可选）

指定在每一步生成时，返回模型最大概率的候选 Token 个数。

取值范围：[0,5]

仅当 logprobs 为 true 时生效。

stop string 或 array （可选）

使用stop参数后，当模型生成的文本即将包含指定的字符串或token_id时，将自动停止生成。

您可以在stop参数中传入敏感词来控制模型的输出。

stop为array类型时，不可以将token_id和字符串同时作为元素输入，比如不可以指定stop为["你好",104307]。

tools array （可选）

可供模型调用的工具数组，可以包含一个或多个工具对象。一次 Function Calling 流程模型会从中选择其中一个工具（开启parallel_tool_calls参数可能选择多个工具）。使用 tools 时需要同时指定result_format参数为"message"。无论是发起 Function Calling，还是向模型提交工具函数的执行结果，均需设置tools参数。

目前不支持通义千问VL/Audio，也不建议用于数学和代码模型。

属性

  

通过HTTP调用时，请将 tools 放入 parameters JSON 对象中。暂时不支持qwen-audio系列模型。

tool_choice string 或 object （可选）

在使用tools参数时，用于控制模型调用指定工具。有三种取值：

  

"none"表示不调用工具。tools参数为空时，默认值为"none"。

"auto"表示由模型判断是否调用工具，可能调用也可能不调用。tools参数不为空时，默认值为"auto"。

object结构可以指定模型调用的工具。例如tool_choice={"type": "function", "function": {"name": "user_function"}}。

  

type只支持指定为"function"。

function

  

name表示期望被调用的工具名称，例如"get_current_time"。

Java SDK中为toolChoice。通过HTTP调用时，请将 tool_choice 放入 parameters 对象中。

parallel_tool_calls boolean （可选）默认值为 false

是否开启并行工具调用。参数为true时开启，为false时不开启。并行工具调用详情请参见：并行工具调用。

translation_options object （可选）

当您使用翻译模型时需要配置的翻译参数。

属性

  

Java SDK中为translationOptions。通过HTTP调用时，请将 translation_options 放入 parameters 对象中。

enable_search boolean （可选）

模型在生成文本时是否使用互联网搜索结果进行参考。取值如下：

  

true：启用互联网搜索，模型会将搜索结果作为文本生成过程中的参考信息，但模型会基于其内部逻辑判断是否使用互联网搜索结果。

如果模型没有搜索互联网，建议优化Prompt，或设置search_options中的forced_search参数开启强制搜索。

false（默认）：关闭互联网搜索。

支持的模型

  

Java SDK中为enableSearch。通过HTTP调用时，请将 enable_search 放入 parameters 对象中。

启用互联网搜索功能可能会增加 Token 的消耗。

search_options object （可选）

联网搜索的策略。仅当enable_search为true时生效。

通过HTTP调用时，请将 search_options 放入 parameters 对象中。Java SDK中为searchOptions。

属性

  

X-DashScope-DataInspection string （可选）

在通义千问 API 的内容安全能力基础上，是否进一步识别输入输出内容的违规信息。取值如下：

  

'{"input":"cip","output":"cip"}'：进一步识别；

不设置该参数：不进一步识别。

通过 HTTP 调用时请放入请求头：-H "X-DashScope-DataInspection: {\"input\": \"cip\", \"output\": \"cip\"}"；

通过 Python SDK 调用时请通过headers配置：headers={'X-DashScope-DataInspection': '{"input":"cip","output":"cip"}'}。

详细使用方法请参见内容安全。

不支持通过 Java SDK 设置。

不适用于 Qwen-VL、Qwen-Audio 系列模型。

chat响应对象（流式与非流式输出格式一致）

{

"status_code": 200,

"request_id": "902fee3b-f7f0-9a8c-96a1-6b4ea25af114",

"code": "",

"message": "",

"output": {

"text": null,

"finish_reason": null,

"choices": [

{

"finish_reason": "stop",

"message": {

"role": "assistant",

"content": "我是阿里云开发的一款超大规模语言模型，我叫通义千问。"

}

}

]

},

"usage": {

"input_tokens": 22,

"output_tokens": 17,

"total_tokens": 39

}}

status_code string

本次请求的状态码。200 表示请求成功，否则表示请求失败。

Java SDK不会返回该参数。调用失败会抛出异常，异常信息为status_code和message的内容。

request_id string

本次调用的唯一标识符。

Java SDK返回参数为requestId。

code string

错误码，调用成功时为空值。

只有Python SDK返回该参数。

output object

调用结果信息。

属性

  

usage map

本次chat请求使用的Token信息。

属性

  

错误码

如果模型调用失败并返回报错信息，请参见错误信息进行解决。

  

import osimport dashscope

  

messages = [

{'role':'system','content':'you are a helpful assistant'},

{'role': 'user','content': '你是谁？'}

]

responses = dashscope.Generation.call(

# 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv('DASHSCOPE_API_KEY'),

model="qwen-plus", # 此处以qwen-plus为例，可按需更换模型名称。模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models

messages=messages,

result_format='message',

stream=True,

incremental_output=True

)for response in responses:

print(response)

  

  

  

大模型收到输入后并不是一次性生成最终结果，而是逐步地生成中间结果，最终结果由中间结果拼接而成。用流式输出的方式调用大模型 API，能够实时返回中间结果，减少用户的阅读等待时间，并降低请求的超时风险。

概述

相比非流式输出，流式输出可以实时地将中间结果返回，您可以在模型进行输出的同时进行阅读，减少等待模型回复的时间；并且当输出内容较长时，有效降低请求超时的风险。

请求超时错误的报错信息：Request timed out, please try again later. 或 Response timeout。

以下为流式输出与非流式输出的效果对比。

⏱️ 等待时间：3 秒

已关闭流式输出

  

  

以上组件仅供您参考，并未真实发送请求。

如何使用

前提条件

您需要已获取API Key并配置API Key到环境变量。如果通过OpenAI SDK或DashScope SDK进行调用，还需要安装SDK。

开始使用

对于 Qwen3 开源版、QwQ 商业版与开源版、QVQ 模型，仅支持流式输出方式调用。

  

OpenAI兼容DashScope

  

  

通过 OpenAI 兼容方式开启流式输出十分简便，只需在请求参数中设置 stream 为 true 即可，详情请参见以下代码。

PythonNode.jscurl

  

  

流式输出默认不会返回本次请求所使用的 Token 量。您可以通过设置stream_options参数为{"include_usage": True}，使最后一个返回的 chunk 包含本次请求所使用的 Token 量。

我们未来会将stream_options参数默认设置为{"include_usage": True}，这会使最后一个chunk的choices字段成为空列表，我们建议您参考本文的最新代码，在业务代码中加上if chunk.choices:的判断条件。

  

import osfrom openai import OpenAI

  

client = OpenAI(

# 若没有配置环境变量，请用阿里云百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1"

)

  

completion = client.chat.completions.create(

model="qwen-plus", # 此处以qwen-plus为例，您可按需更换模型名称。模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models

messages=[

{"role": "system", "content": "You are a helpful assistant."},

{"role": "user", "content": "你是谁？"}

],

stream=True,

# Qwen3模型通过enable_thinking参数控制思考过程（开源版默认True，商业版默认False）

# 使用Qwen3开源版模型时，请将下行取消注释，否则会报错

# extra_body={"enable_thinking": False},

)

  

full_content = ""print("流式输出内容为：")for chunk in completion:

# 如果stream_options.include_usage为True，则最后一个chunk的choices字段为空列表，需要跳过（可以通过chunk.usage获取 Token 使用量）

if chunk.choices:

full_content += chunk.choices[0].delta.content

print(chunk.choices[0].delta.content)print(f"完整内容为：{full_content}")

返回结果

流式输出内容为：

  

我是来自

阿里

云

的大规模语言模型

，我叫通

义千问。

  

完整内容为：我是来自阿里云的大规模语言模型，我叫通义千问。

错误码

如果模型调用失败并返回报错信息，请参见错误信息进行解决。

常见问题

Q1：开启流式输出对模型的回复效果是否有影响？

A1：不会有影响。

Q2：开启流式输出功能需要额外付费吗？

A2：不需要额外付费，流式输出与非流式输出计费规则一样，都是按照输入与输出的 Token 计费。

  

import osfrom dashscope import Generation

  

  

messages = [

{'role':'system','content':'you are a helpful assistant'},

{'role': 'user','content': '你是谁？'}]

responses = Generation.call(

# 若没有配置环境变量，请用阿里云百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"),

model="qwen-plus", # 此处以qwen-plus为例，您可按需更换模型名称。模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models

messages=messages,

result_format='message',

stream=True,

# 增量式流式输出

incremental_output=True,

# Qwen3模型通过enable_thinking参数控制思考过程（开源版默认True，商业版默认False）

# 使用Qwen3开源版模型时，若未启用流式输出，请将下行取消注释，否则会报错

# enable_thinking=False

)

full_content = ""print("流式输出内容为：")for response in responses:

full_content += response.output.choices[0].message.content

print(response.output.choices[0].message.content)print(f"完整内容为：{full_content}")

  

文本生成是一种人工智能技术，它基于深度学习算法，根据给定的提示信息创作出有逻辑、连贯的文本内容。

文本生成所需的输入（提示或Prompt）可以是简单的关键词、一句话概述或是更复杂的指令和上下文信息。文本生成模型通过分析大量现有数据，学习语言模式，广泛应用于以下领域：

内容创作：自动生成新闻报道、商品介绍、短视频脚本等。

客户服务：在聊天机器人中应用，提供24小时客服支持，解答常见问题。

文本翻译：快速准确地将文本从一种语言翻译成另一种语言。

摘要生成：为长篇文章、报告、客户邮件自动生成摘要。

法律文档编写：自动化生成合同模板、法律意见书的基础框架。

文本生成示例：根据需求提取客户邮件中的关键信息

Prompt

请从这封客户反馈邮件中提取以下信息：1.客户信息 2.软件版本 3.错误代码 4.问题描述 5.操作系统 6.其他相关细节

------------

邮件正文：

主题：【报障求助】智能百炼助手启动故障

尊敬的百炼客服和技术支持团队，

我是来自通义科技的张伟，我的用户ID是12345。我正在使用的智能百炼助手软件版本为V3.1.8，在此向您报告一个严重影响工作进度的技术问题，望尽快协助解决。

自昨日下午起，我在启动智能百炼助手时遇到严重障碍，软件启动过程卡在初始化界面，错误码为ERR-2007，并弹出错误提示“数据库连接失败”，导致所有功能模块无法正常使用。这一情况已经持续至今，严重影响了我司的办公效率。

我目前使用的服务器操作系统是Windows 10版本1909，针对64位架构进行优化。在遇到问题后，我已经采取了若干初步故障排除措施，其中包括完全关闭并重新启动系统以试图清除可能的临时软件冲突或系统挂起状态，以及彻底卸载并重新安装相关软件，旨在消除可能存在的软件损坏或配置错误问题。然而，尽管进行了这些常规解决尝试，问题仍然持续存在，未见任何改善。

为了便于更深入地诊断问题，我已将详细的错误截图和系统日志文件作为附件一并提供。这些材料应当能精确展示错误发生时的软件状态、异常详情以及任何相关的错误代码，为快速定位并解决当前遇到的技术障碍提供了关键信息。

期待您的尽快回复！

模型输出

1.客户信息：通义科技张伟（ID12345）

2.软件版本：智能百炼助手V3.1.8

3.错误代码：ERR-2007

4.问题描述：能百炼助手在启动过程中卡在初始化界面，出现“数据库连接失败”的错误提示，导致所有功能模块无法使用，问题自昨日下午开始持续存在。

5.操作系统：Win10 1909 64位

6.其他相关细节：已尝试的解决措施包括重启系统和重装软件，但问题未解决。附件包含错误截图与日志文件。

更多示例可以参考文本生成样例。

文本生成模型

百炼大模型服务平台支持通义千问商业版、通义千问开源版与一些知名第三方模型，详细的模型列表请参考文本生成模型列表。

通义千问商业版

通义千问开源版

第三方模型（DeepSeek等）

模型选型建议

通义千问-Max、通义千问-Plus 和通义千问-Turbo 均适用于智能客服、文本创作（如撰写文稿、文案创作）、文本润色以及总结摘要等多种场景。如果您暂时不确定选择哪个模型，建议优先尝试使用通义千问-Plus，它在效果、速度和成本上相对均衡。

推理能力：通义千问-Max > 通义千问-Plus > 通义千问-Turbo

响应速度：通义千问-Turbo > 通义千问-Plus > 通义千问-Max

三个模型都兼容OpenAI 调用方式，相关细节请参考如何通过OpenAI接口调用通义千问模型。

如果您有明确的业务诉求，也可以选择更适合该场景的模型，比如：

  

希望实现超长文档的总结分析，可以尝试Qwen-Long（最大千万Token）、通义千问-Turbo（最大百万Token）或通义千问-Plus（最大131,072 Token）。

数学解题场景推荐使用通义千问数学模型。

代码场景推荐使用通义千问代码模型。

法律领域推荐使用通义法睿，适用于检索法律知识、生成法律文书、检查合同条款等。

机器翻译场景推荐使用通义千问翻译模型，适用于中英互译、中文与小语种互译、英文与小语种互译。

您也可以结合具体任务充分体验和评测，对比模型表现后再做决定：

  

使用模型体验功能，通过选择多个文本生成模型，根据相同输入对模型能力进行快速、直观地横向比较。

使用模型评测功能，系统地比较模型表现。通过使用不同的模型评测方法，帮助您系统地评估模型表现。

更多可量化对比的信息可前往：模型计费详情、性能与限流。

如何使用

文本生成模型将接收的信息作为提示（Prompt），并返回一个根据提示信息生成的输出。百炼支持 OpenAI SDK、DashScope SDK、HTTP 接入方式。

本文以调用通义千问模型为例，介绍如何使用文本生成模型。使用 OpenAI 接口进行模型调用的完整参数列表参考 OpenAI 兼容 API 参考，DashScope 模型调用的完整参数列表参考DashScope API 参考。

消息类型

您通过API与大模型进行交互时的输入和输出也被称为消息（Message）。每条消息都属于一个角色（Role），角色包括系统（System）、用户（User）和助手（Assistant）。

系统消息（System Message，也称为 System Prompt）：用于告知模型要扮演的角色或行为。例如，您可以让模型扮演一个严谨的科学家等。默认值是“You are a helpful assistant”。您也可以将此类指令放在用户消息中，但放在系统消息中会更有效。

用户消息（User Message）：您输入给模型的文本。

助手消息（Assistant Message）：模型的回复。您也可以预先填写助手消息，作为后续助手消息的示例。

快速开始

API 使用前提：

已获取API Key并完成配置API Key到环境变量。

已安装SDK。

OpenAI兼容DashScope

  

  

您可以通过 OpenAI SDK 或 OpenAI 兼容的HTTP方式快速体验通义千问模型。

完整参数列表参考 OpenAI 兼容 API 参考。

PythonJavaNode.jsHTTP

  

  

示例代码

import osfrom openai import OpenAItry:

client = OpenAI(

# 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",

)

  

completion = client.chat.completions.create(

# 模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models

model="qwen-plus",

messages=[

{"role": "system", "content": "You are a helpful assistant."},

{"role": "user", "content": "你是谁？"},

],

)

print(completion.choices[0].message.content)except Exception as e:

print(f"错误信息：{e}")

print("请参考文档：https://help.aliyun.com/zh/model-studio/developer-reference/error-code")

返回结果

我是来自阿里云的超大规模语言模型，我叫通义千问。

异步调用

您可以使用Asyncio接口调用实现并发，提高程序的效率。示例代码如下：

OpenAI SDKDashScope SDK

  

  

示例代码

import osimport asynciofrom openai import AsyncOpenAIimport platform# 创建异步客户端实例

client = AsyncOpenAI(

# 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1"

)# 定义异步任务列表async def task(question):

print(f"Sending question: {question}")

response = await client.chat.completions.create(

messages=[

{"role": "user", "content": question}

],

model="qwen-plus", # 模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models

)

print(f"Received answer: {response.choices[0].message.content}")# 主异步函数async def main():

questions = ["你是谁？", "你会什么？", "天气怎么样？"]

tasks = [task(q) for q in questions]

await asyncio.gather(*tasks)if __name__ == '__main__':

# 设置事件循环策略

if platform.system() == 'Windows':

asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

# 运行主协程

asyncio.run(main(), debug=False)

控制生成的常用参数

Temperature 和 top_p

这两个参数都用于控制模型生成文本的多样性。temperature 或 top_p 越高，生成的文本更多样，反之生成的文本更确定。

具有多样性的文本，适用于创意写作（如小说、广告文案）、头脑风暴、聊天应用等场景。

具有确定性的文本，适用于有明确答案（如问题分析、选择题、事实查询）或要求用词准确（如技术文档、法律文本、新闻报导、学术论文）的场景。

原理介绍

API 参考

使用 OpenAI 接口进行模型调用的完整参数列表参考 OpenAI 兼容 API 参考，DashScope 模型调用的完整参数列表参考DashScope API 参考。

了解更多

提示（Prompt）工程

提示（Prompt）是输入给大语言模型的文本信息，用于明确地告诉模型想要解决的问题或完成的任务，也是模型理解需求并生成相关、准确内容的基础。通过精心设计和优化 Prompt，向模型“明确”任务目的，使模型输出的结果更符合预期，这一过程被称之为"提示工程（Prompt Engineering）"。这个过程包括以下关键步骤：

  

如果您对提示工程感兴趣，请前往文生文Prompt指南了解如何构建有效的Prompt来提升模型表现。

也可以浏览百炼服务平台的 Prompt工程页面，从而快速了解如何利用模板来快速生成所需的文本内容。

多模态能力

多模态能力是指模型能够处理和结合多种不同类型的数据模态（如文本、图像、音频、视频等）进行信息的理解、处理和生成的能力。这种能力使得模型能够更全面地理解和生成内容，增强上下文理解，提高模型表现。

当前百炼支持的多模态模型有：

通义千问VL（文+图->文）：具有图像理解能力的通义千问模型，能完成 OCR、视觉推理、本文理解等任务，支持超百万像素分辨率和任意宽高比的图像。

通义千问Omni（全模态-> 文+音）：支持输入多种模态的数据，包括视频、音频、图片、文本，并输出音频与文本。

通义千问Audio（文+音->文）：具有音频理解能力的通义千问模型，不仅能对输入的音频进行转录，还具备更深层次的语义理解、情感分析、音频事件检测、语音聊天等能力。

语音识别模型（音->文）：识别并转写音频中的语音内容，支持中文（含粤语等各种方言）、英文、日语、韩语等。

常见问题

Q：通义千问 API 为何无法分析网页链接？

A：解析网页链接本身并不属于大模型 API 的能力，您可以结合 Python 的 Beautiful Soup 等网页抓取工具实现读取网页的功能。

Q：网页端通义千问和通义千问 API 的回复为什么不一致？

A：网页端是在通义千问 API 的基础上做了额外的工程优化，因此可以达到解析网页、联网搜索、画图、创作 PPT等功能，这些本身并不属于大模型 API 的能力。

Q：如何处理模型超时的情况？

A：我们推荐您使用流式输出来降低超时风险。使用非流式输出方式调用模型服务，180秒内模型没有结束输出通常会触发超时报错。为了提升用户体验，超时后响应体中会将已生成的内容返回，且不再报超时错误。如果响应头包含 x-dashscope-partialresponse：true，表示本次响应触发了超时。

如果您无法获取到响应头参数（如通过 SDK 调用），可以通过返回的 finish_reason字段来辅助判断，如果 finish_reason 为"null”，表示当前生成内容是不完整的（但不一定是由于触发了超时）。

您可以使用前缀续写功能，将已生成的内容添加到 messages 数组并再次发出请求，使大模型继续生成内容。详情请参见：基于超时返回的内容继续生成。

Java SDK 暂不支持前缀续写功能。

  

  

import asyncioimport platformfrom dashscope.aigc.generation import AioGenerationimport os# 定义异步任务列表async def task(question):

print(f"Sending question: {question}")

response = await AioGeneration.call(

# 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"),

model="qwen-plus", # 模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models

prompt=question

)

print(f"Received answer: {response.output.text}")# 主异步函数async def main():

questions = ["你是谁？", "你会什么？", "天气怎么样？"]

tasks = [task(q) for q in questions]

await asyncio.gather(*tasks)if __name__ == '__main__':

# 设置事件循环策略

if platform.system() == 'Windows':

asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

# 运行主协程

asyncio.run(main(), debug=False)

  

  

Qwen3、QwQ（基于Qwen2.5） 与 DeepSeek-R1 模型具有强大的推理能力。模型会先输出思考过程，再输出回答内容。

发送虚拟请求

深度思考模型介绍

阿里云百炼提供了Qwen3、QwQ、DeepSeek-R1 模型的 API。最新的Qwen3系列模型推理能力强，回复速度快，且支持 Function Calling 与联网搜索，推荐您优先使用Qwen3 模型。

  

Qwen3QwQ（基于Qwen2.5）DeepSeek-R1

  

  

Qwen3 模型支持思考模式和非思考模式，您可以通过 enable_thinking 参数实现两种模式的切换。除此之外，模型的能力得到了大幅提升：

推理能力：在数学、代码和逻辑推理等评测中，显著超过 QwQ 和同尺寸的非推理模型，达到同规模业界顶尖水平。

人类偏好能力：创意写作、角色扮演、多轮对话、指令遵循能力均大幅提升，通用能力显著超过同尺寸模型。

Agent 能力：在推理、非推理两种模式下都达到业界领先水平，能精准调用外部工具。

多语言能力：支持100多种语言和方言，多语言翻译、指令理解、常识推理能力都明显提升。

回复格式：修复了之前版本存在的回复格式的问题，如异常 Markdown、中间截断、错误输出 boxed 等问题。

开启enable_thinking有极小概率不会输出思考过程。

思考模式下仅支持流式输出。

商业版模型开源版模型

  

  

通义千问-Plus/Turbo仅latest版本和0428快照属于Qwen3系列，支持开启思考模式。

商业版模型默认不开启思考模式，需要设置 enable_thinking 为 true 才会开启思考模式。

通义千问-Plus

模型名称

版本

上下文长度

最大输入

最大思维链长度

最大回复长度

输入成本

输出成本

免费额度

（注）

（Token数）

（每千Token）

qwen-plus-latest

始终与最新快照版能力相同

Batch调用半价

最新版

131,072

98,304

38,912

16,384

0.0008元

0.016元

各100万 Token

有效期：百炼开通后180天内

qwen-plus-2025-04-28

又称qwen-plus-0428

快照版

通义千问-Turbo

模型名称

版本

上下文长度

最大输入

最大思维链长度

最大回复长度

输入成本

输出成本

免费额度

（注）

（Token数）

（每千Token）

qwen-turbo-latest

始终与最新快照版能力相同

Batch调用半价

最新版

131,072

98,304

38,912

16,384

0.0003元

0.006元

各100万 Token

有效期：百炼开通后180天内

qwen-turbo-2025-04-28

又称qwen-plus-0428

快照版

并发限流请参考限流。

快速开始

API 使用前提：已获取API Key并完成配置API Key到环境变量。如果通过SDK调用，需要安装 OpenAI 或 DashScope SDK（DashScope Java SDK 版本需要不低于2.19.4）。

您可以运行以下代码，通过流式输出的方式调用深度思考模型。通过响应的reasoning_content字段获取思考过程，content字段获取回复内容。

OpenAI兼容DashScope

  

  

PythonNode.jsHTTP

  

  

示例代码

from openai import OpenAIimport os# 初始化OpenAI客户端

client = OpenAI(

# 如果没有配置环境变量，请用阿里云百炼API Key替换：api_key="sk-xxx"

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",

)

  

messages = [{"role": "user", "content": "你是谁"}]

  

completion = client.chat.completions.create(

model="qwen-plus-2025-04-28", # 您可以按需更换为其它深度思考模型

messages=messages,

# enable_thinking 参数开启思考过程，QwQ 与 DeepSeek-R1 模型总会进行思考，不支持该参数

extra_body={"enable_thinking": True},

stream=True,

# stream_options={

# "include_usage": True

# },

)

  

reasoning_content = "" # 完整思考过程

answer_content = "" # 完整回复

is_answering = False # 是否进入回复阶段print("\n" + "=" * 20 + "思考过程" + "=" * 20 + "\n")for chunk in completion:

if not chunk.choices:

print("\nUsage:")

print(chunk.usage)

continue

  

delta = chunk.choices[0].delta

  

# 只收集思考内容

if hasattr(delta, "reasoning_content") and delta.reasoning_content is not None:

if not is_answering:

print(delta.reasoning_content, end="", flush=True)

reasoning_content += delta.reasoning_content

  

# 收到content，开始进行回复

if hasattr(delta, "content") and delta.content:

if not is_answering:

print("\n" + "=" * 20 + "完整回复" + "=" * 20 + "\n")

is_answering = True

print(delta.content, end="", flush=True)

answer_content += delta.content

返回结果

====================思考过程====================

  

好的，用户问“你是谁”，我需要给出一个准确且友好的回答。首先，我要确认自己的身份，即通义千问，由阿里巴巴集团旗下的通义实验室研发。接下来，应该说明我的主要功能，比如回答问题、创作文字、逻辑推理等。同时，要保持语气亲切，避免过于技术化，让用户感觉轻松。还要注意不要使用复杂术语，确保回答简洁明了。另外，可能需要加入一些互动元素，邀请用户提问，促进进一步交流。最后，检查是否有遗漏的重要信息，比如我的中文名称“通义千问”和英文名称“Qwen”，以及所属公司和实验室。确保回答全面且符合用户期望。

====================完整回复====================

  

你好！我是通义千问，是阿里巴巴集团旗下的通义实验室自主研发的超大规模语言模型。我可以回答问题、创作文字、进行逻辑推理、编程等，旨在为用户提供高质量的信息和服务。你可以叫我Qwen，或者直接叫我通义千问。有什么我可以帮你的吗？

多轮对话

大模型 API 默认不会记录您的历史对话信息。多轮对话功能可以让大模型“拥有记忆”，满足如追问、信息采集等需要连续交流的场景。深度思考模型会返回reasoning_content（思考过程）与content（回复内容）字段，您可以将content字段通过{'role': 'assistant', 'content':响应的content字段}的形式添加到上下文中，无需添加reasoning_content字段。

OpenAI兼容DashScope

  

  

您可以通过 OpenAI SDK 或 OpenAI 兼容的 HTTP 方式使用多轮对话功能。

PythonNode.jsHTTP

  

  

示例代码

from openai import OpenAIimport os# 初始化OpenAI客户端

client = OpenAI(

# 如果没有配置环境变量，请用阿里云百炼API Key替换：api_key="sk-xxx"

api_key = os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1"

)

  

reasoning_content = "" # 定义完整思考过程

answer_content = "" # 定义完整回复

  

messages = []

conversation_idx = 1while True:

is_answering = False # 判断是否结束思考过程并开始回复

print("="*20+f"第{conversation_idx}轮对话"+"="*20)

conversation_idx += 1

user_msg = {"role": "user", "content": input("请输入你的消息：")}

messages.append(user_msg)

# 创建聊天完成请求

completion = client.chat.completions.create(

# 您可以按需更换为其它深度思考模型

model="qwen-plus-2025-04-28",

messages=messages,

# enable_thinking 参数开启思考过程，QwQ 与 DeepSeek-R1 模型总会进行思考，不支持该参数

extra_body={"enable_thinking": True},

stream=True,

# stream_options={

# "include_usage": True

# }

)

print("\n" + "=" * 20 + "思考过程" + "=" * 20 + "\n")

for chunk in completion:

# 如果chunk.choices为空，则打印usage

if not chunk.choices:

print("\nUsage:")

print(chunk.usage)

else:

delta = chunk.choices[0].delta

# 打印思考过程

if hasattr(delta, 'reasoning_content') and delta.reasoning_content != None:

print(delta.reasoning_content, end='', flush=True)

reasoning_content += delta.reasoning_content

else:

# 开始回复

if delta.content != "" and is_answering is False:

print("\n" + "=" * 20 + "完整回复" + "=" * 20 + "\n")

is_answering = True

# 打印回复过程

print(delta.content, end='', flush=True)

answer_content += delta.content

# 将模型回复的content添加到上下文中

messages.append({"role": "assistant", "content": answer_content})

print("\n")

限制思考长度

深度思考模型有时会输出冗长的推理过程，需要较长时间才能进行回复内容的生成，且会消耗较多 Token。为了解决这一问题，您可以设置thinking_budget参数来约束推理过程的最大长度。

如果模型思考过程生成的 Token 数超过thinking_budget，推理内容会进行截断并立刻开始生成最终回复内容。

该参数仅支持Qwen3 模型设定。

OpenAI兼容DashScope

  

  

PythonNode.jsHTTP

  

  

示例代码

from openai import OpenAIimport os# 初始化OpenAI客户端

client = OpenAI(

# 如果没有配置环境变量，请用阿里云百炼API Key替换：api_key="sk-xxx"

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",

)

  

messages = [{"role": "user", "content": "你是谁"}]

  

completion = client.chat.completions.create(

model="qwen-plus-2025-04-28", # 您可以按需更换为其它深度思考模型

messages=messages,

# enable_thinking 参数开启思考过程，thinking_budget 参数设置最大推理过程 Token 数，两个参数对 QwQ 与 DeepSeek-R1 模型无效

extra_body={

"enable_thinking": True,

"thinking_budget": 50

},

stream=True,

# stream_options={

# "include_usage": True

# },

)

  

reasoning_content = "" # 完整思考过程

answer_content = "" # 完整回复

is_answering = False # 是否进入回复阶段print("\n" + "=" * 20 + "思考过程" + "=" * 20 + "\n")for chunk in completion:

if not chunk.choices:

print("\nUsage:")

print(chunk.usage)

continue

  

delta = chunk.choices[0].delta

  

# 只收集思考内容

if hasattr(delta, "reasoning_content") and delta.reasoning_content is not None:

if not is_answering:

print(delta.reasoning_content, end="", flush=True)

reasoning_content += delta.reasoning_content

  

# 收到content，开始进行回复

if hasattr(delta, "content") and delta.content:

if not is_answering:

print("\n" + "=" * 20 + "完整回复" + "=" * 20 + "\n")

is_answering = True

print(delta.content, end="", flush=True)

answer_content += delta.content

返回结果

====================思考过程====================

  

好的，用户问“你是谁”，我需要给出一个清晰且友好的回答。首先，应该明确自己的身份，即通义千问，由阿里巴巴集团旗下的通义实验室研发。接下来，要说明自己的主要功能，比如回答

====================完整回复====================

  

我是通义千问，是阿里巴巴集团旗下的通义实验室研发的超大规模语言模型。我能够回答问题、创作文字、逻辑推理、编程等，旨在为用户提供帮助和便利。有什么我可以帮您的吗？

联网搜索

由于训练数据的时效性，大模型无法准确回答如股票价格、今日资讯等时效性问题。您可以通过设置enable_search参数为true以启用联网检索功能，使大模型可以基于实时检索数据进行回复。

仅 Qwen3 商业版模型、QwQ 商业版模型（除了qwq-plus-2025-03-05）支持联网搜索。

开启enable_search后，模型会先判断是否需要使用联网搜索能力来回答您的问题：

需要联网搜索

当问题被模型判断需要使用联网搜索能力，模型会根据联网搜索的结果进行回复。

联网搜索功能当前免费，但搜索到的信息会增加 Token 消耗。

不需要联网搜索

模型本身已经可以回答如“你是谁”、“一年有多少天”等简单或常识性的问题。此时模型不会去联网搜索，而是直接进行回答。

如果您希望强制开启联网搜索功能，请参见下文的forced_search参数。

在设置enable_search参数为true后，您可以通过search_options参数来配置联网搜索策略，包括以下方面：

是否强制联网搜索是否返回搜索来源开启角标标注搜索数量

  

  

通过forced_search配置，可选值：

true

强制开启。

false（默认值）

不强制开启。

DashScopeOpenAI兼容

  

  

PythonJavaHTTP

  

  

示例代码

import osimport dashscope

  

messages = [

{'role': 'user', 'content': '哪吒2的票房'}

]

  

response = dashscope.Generation.call(

# 若没有配置环境变量，请用阿里云百炼API Key将下行替换为：api_key="sk-xxx"

api_key=os.getenv('DASHSCOPE_API_KEY'),

# 此处以qwen-plus-2025-04-28为例，可按需更换为支持联网搜索的模型

model="qwen-plus-2025-04-28",

messages=messages,

# 开启深度思考的参数，对 QwQ 模型无效

enable_thinking = True,

enable_search = True, # 开启联网搜索的参数

search_options = {

"forced_search": True, # 强制开启联网搜索

"enable_source": True, # 使返回结果包含搜索来源的信息，OpenAI 兼容方式暂不支持返回

"enable_citation": True, # 开启角标标注功能

"citation_format": "[ref_<number>]", # 角标形式为[ref_i]

"search_strategy": "pro" # 模型将搜索10条互联网信息

},

stream=True,

incremental_output=True,

result_format="message",

)# 定义完整思考过程

reasoning_content = ""# 定义完整回复

answer_content = ""# 判断是否结束思考过程并开始回复

is_answering = False# 判断是否为第一个chunk，便于打印搜索信息

is_first_chunk = Trueprint("=" * 20 + "搜索信息" + "=" * 20)for chunk in response:

if is_first_chunk:

search_results = chunk.output.search_info["search_results"]

for web in search_results:

print(f"[{web['index']}]: [{web['title']}]({web['url']})")

print("=" * 20 + "思考过程" + "=" * 20)

reasoning_content += chunk.output.choices[0].message.reasoning_content

print(chunk.output.choices[0].message.reasoning_content,end="",flush=True)

is_first_chunk = False

else:

# 如果思考过程与回复皆为空，则忽略

if (chunk.output.choices[0].message.content == "" and

chunk.output.choices[0].message.reasoning_content == ""):

pass

else:

# 如果当前为思考过程

if (chunk.output.choices[0].message.reasoning_content != "" and

chunk.output.choices[0].message.content == ""):

print(chunk.output.choices[0].message.reasoning_content, end="",flush=True)

reasoning_content += chunk.output.choices[0].message.reasoning_content

# 如果当前为回复

elif chunk.output.choices[0].message.content != "":

if not is_answering:

print("\n" + "=" * 20 + "完整回复" + "=" * 20)

is_answering = True

print(chunk.output.choices[0].message.content, end="",flush=True)

answer_content += chunk.output.choices[0].message.content# 如果您需要打印完整思考过程与完整回复，请将以下代码解除注释后运行# print("=" * 20 + "完整思考过程" + "=" * 20 + "\n")# print(f"{reasoning_content}")# print("=" * 20 + "完整回复" + "=" * 20 + "\n")# print(f"{answer_content}")# 如果您需要打印本次请求的 Token 消耗，请将以下代码解除注释后运行# print("\n"+"="*20+"Token 消耗"+"="*20)# print(chunk.usage)

返回结果

====================搜索信息====================

[1]: [《哪吒2》票房破119亿元 2025累计票房破200亿!](https://www.1905.com/news/20250217/1714723.shtml)

[2]: [《哪吒2》票房将达215亿,超《阿凡达》成全球第一,5大理由支撑](https://www.360kuai.com/pc/9630dbf8c5a1770de?cota=3&kuai_so=1&sign=360_e39369d1)

[3]: [《哪吒2》票房破135亿:2025年中国电影市场的梦幻开局](https://www.sohu.com/a/862924685_122077416?scm=10001.325_13-109000.0.0.5_32)

[4]: [哪吒2票房突破120亿元](https://baijiahao.baidu.com/s?id=1824275513693903228)

[5]: [哪吒2票房突破153亿](https://m.gmw.cn/2025-03/23/content_1303998589.htm)

[6]: [哪吒2总票房破131亿](https://m.gmw.cn/2025-02/22/content_1303977481.htm)

[7]: [2025年娱乐新趋势哪吒2票房破150亿!国产动画如何征服全球市场?](https://m.sohu.com/a/874897462_122173903/?scm=10001.334_13-101000-0_922.0-0.0.a2_5X162X1746)

[8]: [哪吒2全球票房破156亿](https://m.gmw.cn/2025-04/09/content_1304011206.htm)

[9]: [《哪吒2》票房彻底疯了 ](https://m.china-xian.com/question/202503/5sy28p2jld.htm)

====================思考过程====================

好的，我现在需要回答用户关于《哪吒2》票房的问题。首先，我要查看提供的知识库内容，找到相关的票房数据。

  

看到有多个引用提到《哪吒2》的票房情况。比如，ref_1提到票房破119亿元，但后面还有其他ref提到更高的数字。ref_3说票房破135亿，ref_5提到全球票房突破153亿，ref_8则提到全球票房破156亿。另外，ref_7提到票房破150亿，而ref_5和ref_8的数据似乎更具体，分别达到153亿和156亿。还有ref_1提到累计票房即将冲击120亿元，但后续的ref_3、ref_5、ref_8都有更高的数据。

  

需要确认这些数据的时间点。例如，ref_1的日期是2025年第6周，也就是2月10日到16日，此时票房是119亿。而ref_3提到的是截至2025年2月24日，票房破135亿。之后ref_5在某个时间点提到153亿，ref_8提到156亿。可能这些数据是逐步更新的，所以最新的应该是ref_8的156亿。不过需要检查是否有更近的引用。

  

另外，ref_7提到的是150亿，而ref_5和ref_8的数据更高。可能不同的ref有不同的统计时间和范围，比如是否包含海外票房。例如，ref_5提到全球票房（含预售及海外）突破153亿，而ref_8也是全球票房破156亿。因此，应该综合这些信息，指出不同时间点的票房成绩，并说明最新数据是156亿。

  

还需要注意是否有矛盾的地方。例如，ref_1提到累计票房突破200亿，但其他ref的数字没有达到这个数值，可能ref_1中的2025全年电影票房累计突破200亿是指整个市场的总票房，而不是《哪吒2》单独的票房。需要仔细区分。

  

总结一下，用户的问题是关于《哪吒2》的票房，需要列出不同时间点的票房数据，并指出最高纪录。同时要引用对应的ref编号，确保准确性。

====================完整回复====================

根据现有资料，《哪吒之魔童闹海》（《哪吒2》）的票房表现如下：

  

1. **国内票房**：截至2025年2月24日，该片国内票房已突破135亿元[ref_3]，随后持续增长，累计票房接近150亿元[ref_7]。

  

2. **全球票房**：

- 截至2025年4月，影片全球票房（含预售及海外）已突破**156亿元**[ref_8]。

- 此前，全球票房曾突破**153亿元**[ref_5]，并位居全球影史票房榜前五[ref_8]。

  

3. **市场地位**：

- 《哪吒2》成为首部进入全球票房前十的非好莱坞动画电影，且在欧洲37国同步上映，创下华语影片发行新纪录[ref_7]。

- 影片还以150亿元票房成绩超越《阿凡达》（2009年第一部），一度登上全球票房榜首[ref_2]。

  

4. **其他数据**：

- 2025年第6周（2月10日-16日），周票房达38.4亿元，累计票房接近120亿元[ref_1]。

- 影片在海外市场表现亮眼，例如在英国超级点映票房达100万美元，创造国际动画电影点映新纪录[ref_1]。

  

综上，《哪吒2》的票房成绩体现了其在国内及全球市场的巨大影响力，最终全球票房有望进一步攀升。

Function Calling（工具调用）

虽然深度思考模型拥有强大的推理能力，但无法与外部世界进行交互。Function Calling 通过引入外部工具，可以帮助深度思考模型实现天气查询、数据库查询、发送邮件等功能。

DeepSeek-R1 系列模型暂不支持 Function Calling。

Qwen3、QwQ 模型会在思考完成后进行工具调用信息的输出，tool_choice参数只支持设置为"auto"（默认值，表示由模型自主选择工具）或"none"（强制模型不选择工具）。

OpenAI兼容DashScope

  

  

PythonNode.jsHTTP

  

  

示例代码

import osfrom openai import OpenAI# 初始化OpenAI客户端，配置阿里云DashScope服务

client = OpenAI(

# 若没有配置环境变量，请用阿里云百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"), # 从环境变量读取API密钥

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",

)# 定义可用工具列表

tools = [

# 工具1 获取当前时刻的时间

{

"type": "function",

"function": {

"name": "get_current_time",

"description": "当你想知道现在的时间时非常有用。",

"parameters": {} # 无需参数

}

},

# 工具2 获取指定城市的天气

{

"type": "function",

"function": {

"name": "get_current_weather",

"description": "当你想查询指定城市的天气时非常有用。",

"parameters": {

"type": "object",

"properties": {

"location": {

"type": "string",

"description": "城市或县区，比如北京市、杭州市、余杭区等。"

}

},

"required": ["location"] # 必填参数

}

}

}

]

  

messages = [{"role": "user", "content": input("请输入问题：")}]

completion = client.chat.completions.create(

# 此处以qwen-plus-2025-04-28为例，可更换为其它深度思考模型

model="qwen-plus-2025-04-28",

messages=messages,

extra_body={

# 开启深度思考，该参数对 QwQ 模型无效

"enable_thinking": True

},

tools=tools,

parallel_tool_calls=True,

stream=True,

# 解除注释后，可以获取到token消耗信息

# stream_options={

# "include_usage": True

# }

)

  

reasoning_content = "" # 定义完整思考过程

answer_content = "" # 定义完整回复

tool_info = [] # 存储工具调用信息

is_answering = False # 判断是否结束思考过程并开始回复print("="*20+"思考过程"+"="*20)for chunk in completion:

if not chunk.choices:

# 处理用量统计信息

print("\n"+"="*20+"Usage"+"="*20)

print(chunk.usage)

else:

delta = chunk.choices[0].delta

# 处理AI的思考过程（链式推理）

if hasattr(delta, 'reasoning_content') and delta.reasoning_content is not None:

reasoning_content += delta.reasoning_content

print(delta.reasoning_content,end="",flush=True) # 实时输出思考过程

# 处理最终回复内容

else:

if not is_answering: # 首次进入回复阶段时打印标题

is_answering = True

print("\n"+"="*20+"回复内容"+"="*20)

if delta.content is not None:

answer_content += delta.content

print(delta.content,end="",flush=True) # 流式输出回复内容

# 处理工具调用信息（支持并行工具调用）

if delta.tool_calls is not None:

for tool_call in delta.tool_calls:

index = tool_call.index # 工具调用索引，用于并行调用

# 动态扩展工具信息存储列表

while len(tool_info) <= index:

tool_info.append({})

# 收集工具调用ID（用于后续函数调用）

if tool_call.id:

tool_info[index]['id'] = tool_info[index].get('id', '') + tool_call.id

# 收集函数名称（用于后续路由到具体函数）

if tool_call.function and tool_call.function.name:

tool_info[index]['name'] = tool_info[index].get('name', '') + tool_call.function.name

# 收集函数参数（JSON字符串格式，需要后续解析）

if tool_call.function and tool_call.function.arguments:

tool_info[index]['arguments'] = tool_info[index].get('arguments', '') + tool_call.function.arguments

print(f"\n"+"="*19+"工具调用信息"+"="*19)if not tool_info:

print("没有工具调用")else:

print(tool_info)

返回结果

输入“四个直辖市的天气”，得到以下返回结果：

====================思考过程====================

好的，用户问的是“四个直辖市的天气”。首先，我需要明确四个直辖市是哪几个。根据中国的行政区划，直辖市包括北京、上海、天津和重庆。所以用户想知道这四个城市的天气情况。

  

接下来，我需要检查可用的工具。提供的工具中有get_current_weather函数，参数是location，类型字符串。每个城市需要单独查询，因为函数一次只能查一个地点。因此，我需要为每个直辖市调用一次这个函数。

  

然后，我需要考虑如何生成正确的工具调用。每个调用应该包含城市名称作为参数。比如，第一个调用是北京，第二个是上海，依此类推。确保参数名称是location，值是正确的城市名。

  

另外，用户可能希望得到每个城市的天气信息，所以需要确保每个函数调用都正确无误。可能需要连续调用四次，每次对应一个城市。不过，根据工具的使用规则，可能需要分多次处理，或者一次生成多个调用。但根据示例，可能每次只调用一个函数，所以可能需要逐步进行。

  

最后，确认是否有其他需要考虑的因素，比如参数是否正确，城市名称是否准确，以及是否需要处理可能的错误情况，比如城市不存在或API不可用。但目前看来，四个直辖市都是明确的，应该没问题。

====================回复内容====================

  

===================工具调用信息===================

[{'id': 'call_767af2834c12488a8fe6e3', 'name': 'get_current_weather', 'arguments': '{"location": "北京市"}'}, {'id': 'call_2cb05a349c89437a947ada', 'name': 'get_current_weather', 'arguments': '{"location": "上海市"}'}, {'id': 'call_988dd180b2ca4b0a864ea7', 'name': 'get_current_weather', 'arguments': '{"location": "天津市"}'}, {'id': 'call_4e98c57ea96a40dba26d12', 'name': 'get_current_weather', 'arguments': '{"location": "重庆市"}'}]

在得到 Function Calling 输出的工具信息后，您可以参考运行工具函数与大模型总结工具函数输出，使大模型能够根据工具运行的结果进行回答。

开启/关闭思考模式

除了通过enable_thinking参数设置，Qwen3 模型还提供了通过提示词动态控制思考模式的便捷方法。当enable_thinking为true时，您可以在提示词中加上/no_think，使 Qwen3 模型在之后的回复关闭思考模式。若您需要在多轮对话重新开启思考模式，只需在最新输入的提示词加上/think 。

在多轮对话中，模型会遵循最近的/think 或/no_think指令。

如果 Qwen3 模型没有输出思考过程，输出 Token 将按非思考模式的价格计费。

OpenAI兼容DashScope

  

  

PythonNode.jsHTTP

  

  

示例代码

from openai import OpenAIimport os# 初始化OpenAI客户端

client = OpenAI(

# 如果没有配置环境变量，请用阿里云百炼API Key替换：api_key="sk-xxx"

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",

)# 在 prompt 加上/no_think，即使enable_thinking设为true也会关闭思考模式。

messages = [{"role": "user", "content": "你是谁/no_think"}]

completion = client.chat.completions.create(

model="qwen-plus-2025-04-28", # 您可以按需更换为其它Qwen3 模型

messages=messages,

# enable_thinking 参数开启思考过程，QwQ 与 DeepSeek-R1 模型总会进行思考，不支持该参数

extra_body={"enable_thinking": True},

stream=True,

# stream_options={

# "include_usage": True

# },

)

  

reasoning_content = "" # 完整思考过程

answer_content = "" # 完整回复

is_answering = False # 是否进入回复阶段print("\n" + "=" * 20 + "思考过程" + "=" * 20 + "\n")for chunk in completion:

if not chunk.choices:

print("\nUsage:")

print(chunk.usage)

continue

  

delta = chunk.choices[0].delta

  

# 只收集思考内容

if hasattr(delta, "reasoning_content") and delta.reasoning_content is not None:

if not is_answering:

print(delta.reasoning_content, end="", flush=True)

reasoning_content += delta.reasoning_content

  

# 收到content，开始进行回复

if hasattr(delta, "content") and delta.content:

if not is_answering:

print("\n" + "=" * 20 + "完整回复" + "=" * 20 + "\n")

is_answering = True

print(delta.content, end="", flush=True)

answer_content += delta.content

返回结果

====================思考过程====================

  

  

====================完整回复====================

  

我是通义千问，阿里巴巴集团旗下的通义实验室自主研发的超大规模语言模型。我可以帮助你回答问题、创作文字、进行逻辑推理、编程等任务。如果你有任何问题或需要帮助，欢迎随时向我提问！

非流式输出

非流式输出

注意事项

为了达到模型的最佳推理效果，不建议设置 System Message。建议您通过 User Message 传入模型的设定、输出格式、要求等信息。

该注意事项不适用于 deepseek-r1-0528 模型。

常见问题

Q：怎么关闭思考过程？

  

Q：免费额度用完后如何购买 Token？

  

Q：如何接入 Chatbox、Cherry Studio、Cline或 Dify？

  

Q：可以上传图片或文档进行提问吗？

  

Q：如何在使用 LangChain 时输出思考过程？

  

Q：如何查看Token消耗量及调用次数？

  

API 参考

深度思考模型的输入与输出参数请参见通义千问。

错误码

如果执行报错，请参见错误信息进行解决。

  

import osfrom dashscope import Generation# 在 prompt 加上/no_think，即使enable_thinking设为true也会关闭思考模式。

messages = [{"role": "user", "content": "你是谁？ /no_think"}]

  

completion = Generation.call(

# 若没有配置环境变量，请用阿里云百炼API Key将下行替换为：api_key = "sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"),

# 可按需更换为其它Qwen3模型

model="qwen-plus-2025-04-28",

messages=messages,

result_format="message",

enable_thinking=True,

stream=True,

incremental_output=True,

)# 定义完整思考过程

reasoning_content = ""# 定义完整回复

answer_content = ""# 判断是否结束思考过程并开始回复

is_answering = Falseprint("=" * 20 + "思考过程" + "=" * 20)for chunk in completion:

# 如果思考过程与回复皆为空，则忽略

if (

chunk.output.choices[0].message.content == ""

and chunk.output.choices[0].message.reasoning_content == ""

):

pass

else:

# 如果当前为思考过程

if (

chunk.output.choices[0].message.reasoning_content != ""

and chunk.output.choices[0].message.content == ""

):

print(chunk.output.choices[0].message.reasoning_content, end="", flush=True)

reasoning_content += chunk.output.choices[0].message.reasoning_content

# 如果当前为回复

elif chunk.output.choices[0].message.content != "":

if not is_answering:

print("\n" + "=" * 20 + "完整回复" + "=" * 20)

is_answering = True

print(chunk.output.choices[0].message.content, end="", flush=True)

answer_content += chunk.output.choices[0].message.content# 如果您需要打印完整思考过程与完整回复，请将以下代码解除注释后运行# print("=" * 20 + "完整思考过程" + "=" * 20 + "\n")# print(f"{reasoning_content}")# print("=" * 20 + "完整回复" + "=" * 20 + "\n")# print(f"{answer_content}")

  

import dashscope

  

tools = [

# 工具1 获取当前时刻的时间

{

"type": "function",

"function": {

"name": "get_current_time",

"description": "当你想知道现在的时间时非常有用。",

"parameters": {} # 因为获取当前时间无需输入参数，因此parameters为空字典

}

},

# 工具2 获取指定城市的天气

{

"type": "function",

"function": {

"name": "get_current_weather",

"description": "当你想查询指定城市的天气时非常有用。",

"parameters": {

"type": "object",

"properties": {

# 查询天气时需要提供位置，因此参数设置为location

"location": {

"type": "string",

"description": "城市或县区，比如北京市、杭州市、余杭区等。"

}

},

"required": ["location"]

}

}

}

]# 定义问题

messages = [{"role": "user", "content": input("请输入问题：")}]

completion = dashscope.Generation.call(

# 此处以qwen-plus-2025-04-28为例，可更换为其它深度思考模型

model="qwen-plus-2025-04-28",

messages=messages,

enable_thinking=True,

tools=tools,

parallel_tool_calls=True,

stream=True,

incremental_output=True,

result_format="message"

)

  

reasoning_content = ""

answer_content = ""

tool_info = []

is_answering = Falseprint("="*20+"思考过程"+"="*20)for chunk in completion:

if chunk.status_code == 200:

msg = chunk.output.choices[0].message

# 处理思考过程

if 'reasoning_content' in msg and msg.reasoning_content:

reasoning_content += msg.reasoning_content

print(msg.reasoning_content, end="", flush=True)

# 处理回复内容

if 'content' in msg and msg.content:

if not is_answering:

is_answering = True

print("\n"+"="*20+"回复内容"+"="*20)

answer_content += msg.content

print(msg.content, end="", flush=True)

# 处理工具调用

if 'tool_calls' in msg and msg.tool_calls:

for tool_call in msg.tool_calls:

index = tool_call['index']

while len(tool_info) <= index:

tool_info.append({'id': '', 'name': '', 'arguments': ''}) # 初始化所有字段

# 增量更新工具ID

if 'id' in tool_call:

tool_info[index]['id'] += tool_call.get('id', '')

# 增量更新函数信息

if 'function' in tool_call:

func = tool_call['function']

# 增量更新函数名称

if 'name' in func:

tool_info[index]['name'] += func.get('name', '')

# 增量更新参数

if 'arguments' in func:

tool_info[index]['arguments'] += func.get('arguments', '')print(f"\n"+"="*19+"工具调用信息"+"="*19)if not tool_info:

print("没有工具调用")else:

print(tool_info)

  

  

from openai import OpenAIimport os# 初始化OpenAI客户端

client = OpenAI(

# 如果没有配置环境变量，请用阿里云百炼API Key替换：api_key="sk-xxx"

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",

)

  

reasoning_content = "" # 定义完整思考过程

answer_content = "" # 定义完整回复

is_answering = False # 判断是否结束思考过程并开始回复# 创建聊天完成请求

completion = client.chat.completions.create(

# 此处以qwen-plus-2025-04-28为例，可更换为其它支持联网搜索的深度思考模型

model="qwen-plus-2025-04-28",

messages=[{"role": "user", "content": "哪吒2的票房"}],

extra_body={

# 开启深度思考的参数，对 QwQ 模型无效

"enable_thinking": True,

"enable_search": True, # 开启联网搜索的参数

"search_options": {

"forced_search": True, # 强制联网搜索的参数

"search_strategy": "pro", # 模型将搜索10条互联网信息

},

},

# QwQ 模型仅支持流式输出方式调用

stream=True,

# 解除以下注释会在最后一个chunk返回Token使用量

stream_options={"include_usage": True},

)print("\n" + "=" * 20 + "思考过程" + "=" * 20 + "\n")for chunk in completion:

# 如果chunk.choices为空，则打印usage

if not chunk.choices:

print("\n" + "=" * 20 + "Usage" + "=" * 20)

print(chunk.usage)

else:

delta = chunk.choices[0].delta

# 打印思考过程

if hasattr(delta, "reasoning_content") and delta.reasoning_content != None:

print(delta.reasoning_content, end="", flush=True)

reasoning_content += delta.reasoning_content

else:

# 开始回复

if delta.content != "" and is_answering is False:

print("\n" + "=" * 20 + "完整回复" + "=" * 20 + "\n")

is_answering = True

# 打印回复过程

print(delta.content, end="", flush=True)

answer_content += delta.content# print("=" * 20 + "完整思考过程" + "=" * 20 + "\n")# print(reasoning_content)# print("=" * 20 + "完整回复" + "=" * 20 + "\n")# print(answer_content)

  

  

  

import osfrom dashscope import Generation

  

messages = [{"role": "user", "content": "你是谁？"}]

  

  

completion = Generation.call(

# 若没有配置环境变量，请用阿里云百炼API Key将下行替换为：api_key = "sk-xxx",

api_key=os.getenv("DASHSCOPE_API_KEY"),

# 可按需更换为其它深度思考模型

model="qwen-plus-2025-04-28",

messages=messages,

result_format="message",

# 开启深度思考，该参数对 QwQ、DeepSeek-R1 模型无效

enable_thinking=True,

# 设置最大推理过程 Token 数，该参数对 QwQ、DeepSeek-R1 模型无效

thinking_budget=50,

stream=True,

incremental_output=True,

)# 定义完整思考过程

reasoning_content = ""# 定义完整回复

answer_content = ""# 判断是否结束思考过程并开始回复

is_answering = Falseprint("=" * 20 + "思考过程" + "=" * 20)for chunk in completion:

# 如果思考过程与回复皆为空，则忽略

if (

chunk.output.choices[0].message.content == ""

and chunk.output.choices[0].message.reasoning_content == ""

):

pass

else:

# 如果当前为思考过程

if (

chunk.output.choices[0].message.reasoning_content != ""

and chunk.output.choices[0].message.content == ""

):

print(chunk.output.choices[0].message.reasoning_content, end="", flush=True)

reasoning_content += chunk.output.choices[0].message.reasoning_content

# 如果当前为回复

elif chunk.output.choices[0].message.content != "":

if not is_answering:

print("\n" + "=" * 20 + "完整回复" + "=" * 20)

is_answering = True

print(chunk.output.choices[0].message.content, end="", flush=True)

answer_content += chunk.output.choices[0].message.content# 如果您需要打印完整思考过程与完整回复，请将以下代码解除注释后运行# print("=" * 20 + "完整思考过程" + "=" * 20 + "\n")# print(f"{reasoning_content}")# print("=" * 20 + "完整回复" + "=" * 20 + "\n")# print(f"{answer_content}")

  

  

在信息抽取场景，您可以通过提示词来指引大模型生成标准格式的 JSON 字符串。但大模型输出内容具有不确定性，返回的内容可能不符合 JSON 格式（比如输出的内容多了```json```，或“以下为JSON字符串”等内容），这会影响到后续的解析步骤。开启结构化输出功能可以确保大模型输出标准格式的 JSON 字符串。

支持的模型

结构化输出功能支持以下模型：

qwen-max 系列

qwen-max-2024-09-19及之后的模型

qwen-plus 系列（非思考模式）

qwen-plus-2024-09-19及之后的模型

qwen-turbo 系列（非思考模式）

qwen-turbo-2024-09-19及之后的模型

qwen-开源系列

qwen3（非思考模式）、qwen2.5系列的文本模型（不含math与coder模型）

开始使用

前提条件

您需要已获取API Key并配置API Key到环境变量。如果通过 OpenAI SDK 或 DashScope SDK 进行调用，需要安装SDK。

使用方法

您的请求需要满足两个条件：

设置参数

您需要设置请求参数response_format为{"type": "json_object"}。

提示词指引

您需要在提示词中指引模型输出 JSON 字符串，否则会报错：'messages' must contain the word 'json' in some form, to use 'response_format' of type 'json_object'.

建议您在提示词中说明每个属性的数据类型，并提供样例给大模型参考。

  

OpenAI兼容DashScope

  

  

PythonNode.jscurl

  

  

示例代码

# 步骤 1：发出请求from openai import OpenAIimport osimport json# 预定义示例响应（用于few-shot提示）

example1_response = json.dumps(

{

"info": {"name": "张三", "age": "25岁", "email": "zhangsan@example.com"},

"hobby": ["唱歌"]

},

ensure_ascii=False

)

example2_response = json.dumps(

{

"info": {"name": "李四", "age": "30岁", "email": "lisi@example.com"},

"hobby": ["跳舞", "游泳"]

},

ensure_ascii=False

)

example3_response = json.dumps(

{

"info": {"name": "王五", "age": "40岁", "email": "wangwu@example.com"},

"hobby": ["Rap", "篮球"]

},

ensure_ascii=False

)

  

client = OpenAI(

api_key=os.getenv("DASHSCOPE_API_KEY"),

base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",

)

  

completion = client.chat.completions.create(

model="qwen-plus",

messages=[

{

"role": "system",

"content": f"""提取name、age、email和hobby（数组类型），输出包含info层和hobby数组的JSON。

示例：

Q：我叫张三，今年25岁，邮箱是zhangsan@example.com，爱好是唱歌

A：{example1_response}

Q：我叫李四，今年30岁，邮箱是lisi@example.com，平时喜欢跳舞和游泳

A：{example2_response}

Q：我的邮箱是wangwu@example.com，今年40岁，名字是王五，会Rap和打篮球

A：{example3_response}"""

},

{

"role": "user",

"content": "大家好，我叫刘五，今年34岁，邮箱是liuwu@example.com，平时喜欢打篮球和旅游",

},

],

response_format={"type": "json_object"},

)

  

json_string = completion.choices[0].message.contentprint(json_string)

返回结果

{"info": {"name": "刘五", "age": "34岁", "email": "liuwu@example.com"}, "hobby": ["打篮球", "旅游"]}

解析 JSON 字符串

在获取大模型输出的 JSON 字符串后，您可以直接使用 JSON 工具进行解析。

PythonNode.jsJava

  

  

# 步骤 2：解析 JSON 字符串。请将以下代码添加到步骤 1 之后import json

json_object = json.loads(json_string)print(json_object)

运行以上代码可以将 JSON 字符串转换为 JSON 对象。

常见问题

Q： 通义千问 API 是否支持根据我提供的 JSON Schema 生成数据？

A：当前通义千问 API 支持根据您输入的提示词生成合法的 JSON 字符串，无法根据您提供的 JSON Schema 来生成。

您可以在提示词中明确描述所需 JSON 的键值结构和数据类型，并提供标准数据样例，这会帮助大模型达到类似效果。

  

  

# 步骤 1：发出请求import osimport jsonimport dashscope# 预定义示例响应（用于few-shot提示）

example1_response = json.dumps(

{

"info": {"name": "张三", "age": "25岁", "email": "zhangsan@example.com"},

"hobby": ["唱歌"]

},

ensure_ascii=False

)

example2_response = json.dumps(

{

"info": {"name": "李四", "age": "30岁", "email": "lisi@example.com"},

"hobby": ["跳舞", "游泳"]

},

ensure_ascii=False

)

example3_response = json.dumps(

{

"info": {"name": "王五", "age": "40岁", "email": "wangwu@example.com"},

"hobby": ["Rap", "篮球"]

},

ensure_ascii=False

)

  

messages=[

{

"role": "system",

"content": f"""提取name、age、email和hobby（数组类型），输出包含info层和hobby数组的JSON。

示例：

Q：我叫张三，今年25岁，邮箱是zhangsan@example.com，爱好是唱歌

A：{example1_response}

Q：我叫李四，今年30岁，邮箱是lisi@example.com，平时喜欢跳舞和游泳

A：{example2_response}

Q：我的邮箱是wangwu@example.com，今年40岁，名字是王五，会Rap和打篮球

A：{example3_response}"""

},

{

"role": "user",

"content": "大家好，我叫刘五，今年34岁，邮箱是liuwu@example.com，平时喜欢打篮球和旅游",

},

]

response = dashscope.Generation.call(

# 若没有配置环境变量，请用阿里云百炼API Key将下行替换为：api_key="sk-xxx",

api_key=os.getenv('DASHSCOPE_API_KEY'),

model="qwen-plus",

messages=messages,

result_format='message',

response_format={'type': 'json_object'}

)

json_string = response.output.choices[0].message.contentprint(json_string)