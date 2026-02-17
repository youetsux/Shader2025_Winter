//───────────────────────────────────────
// テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D g_texture : register(t0); //テクスチャー
SamplerState g_sampler : register(s0); //サンプラー

//───────────────────────────────────────
// コンスタントバッファ
// DirectX 側から送信されてくる、ポリゴン頂点以外の諸情報の定義
//───────────────────────────────────────
cbuffer global : register(b0)
{
    row_major float4x4 matWVP; // ワールド・ビュー・プロジェクションの合成行列
    row_major float4x4 matWorld; // ワールド行列
    row_major float4x4 matNormal; // 法線変換行列
    float4 diffuseColor; // ディフューズ色
    float4 diffusefactor; // ディフューズ係数
    float4 specular; // スペキュラ色
    float4 shininess; // シャイニネス
    float4 ambient; // アンビエント色
    bool useTexture; // テクスチャーを使うかどうか
};

cbuffer gStage : register(b1)
{
    float4 lightPosition;
    float4 eyePosition;
};


//───────────────────────────────────────
// 頂点シェーダー出力＆ピクセルシェーダー入力データ構造体
//───────────────────────────────────────
struct VS_OUT
{
                 //セマンティクス
    float4 wpos : POSITION0; //ワールド座標
    float4 spos : SV_POSITION; //スクリーン位置
    float2 uv : TEXCOORD; //UV座標
    float4 normal : NORMAL; //法線ベクトル
    float4 eyev : POSITION1; //視線ベクトル
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
	//ピクセルシェーダーへ渡す情報
    VS_OUT outData;

	//ローカル座標に、ワールド・ビュー・プロジェクション行列をかけて
    //スクリーン座標に変換し、ピクセルシェーダーへ
    outData.spos = mul(pos, matWVP);
    //ワールド座標もピクセルシェーダーへ
    outData.wpos = mul(pos, matWorld);

    
    normal.w = 0; //法線ベクトルのw成分は0にする
    outData.normal = mul(normal, matNormal);
    
    
    
    outData.uv = uv; //UV座標はそのまま
    outData.eyev = outData.wpos - eyePosition; //視線ベクトルを計算して渡す

    //normal = mul(normal, matNormal); //法線ベクトルをワールド・ビュー・プロジェクション行列で変換
    //normal = normalize(normal); //法線ベクトルを正規化=長さ1に)
    //normal.w = 0; //w成分は0にする
    //float4 light = float4(-1, 0.5, -0.7, 0);
    //light = normalize(light);
    //light.w = 0;
    //outData.color = clamp(dot(normal, light), 0, 1);

	//まとめて出力
    return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
    //float4 light = float4(-1, 0.5, -0.7, 0);
    //return float4(1, 1, 0, 1);
    float4 diffuse;
    float4 ambientColor = ambient;
    float4 ambentFactor = { 0.1, 0.1, 0.1, 1.0 };
    float3 dir = normalize(lightPosition.xyz - inData.wpos.xyz); //ピクセル位置のポリゴンの3次元座標＝wpos
    

    
    float3 k = { 0.2f, 0.2f, 1.0f };
    float len = length(lightPosition.xyz - inData.wpos.xyz);
    float dTerm = 1.0 / (k.x + k.y * len + k.z * len * len); //距離減衰計算
    //float dTerm = 1.0;
    
    float3 N = normalize(inData.normal.xyz);
    diffuse = diffuseColor * diffusefactor * clamp(dot(N, dir), 0, 1) * dTerm;
    

    float3 L = normalize(lightPosition.xyz - inData.wpos.xyz);
    float ndotl = saturate(dot(N, L));
    float spec = 0.0;
    if (ndotl > 0.0)
    {
    
        float3 R = reflect(L, N);
        float3 V = normalize(inData.eyev.xyz);
        spec = pow(saturate(dot(R, V)), 32.0)*ndotl;
    }
    float4 specularCol = specular * spec;
    
    
    float4 diffuseTerm;
    float4 specularTerm = specularCol*dTerm;

    float4 ambientTerm;
    float4 color;
    if (useTexture == 1)
    {
        diffuseTerm = diffuse * g_texture.Sample(g_sampler, inData.uv); //テクスチャーから色を取得
        ambientTerm = ambentFactor * g_texture.Sample(g_sampler, inData.uv);
    }
    else
    {
        diffuseTerm = diffuse*dTerm;
        ambientTerm = ambentFactor * diffuseColor;
    }
    

    color =  diffuseTerm + specularTerm + ambientTerm;
    //color = float4((N.x + 1.0) / 2.0, (N.y + 1.0) / 2.0, (N.z + 1.0) / 2.0, 1.0);
    //float4 ret = float4(inData.uv.x, inData.uv.y, 0, 1);
    //float3 NC = normalize(inData.normal.xyz);
    //return float4(NC * 0.5 + 0.5, 1); // 法線可視化
    return color;
}