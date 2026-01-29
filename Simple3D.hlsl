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
    float4x4 matWVP; // ワールド・ビュー・プロジェクションの合成行列
    float4x4 matWorld; // ワールド行列
    float4x4 matNormal; // 法線変換行列
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
    float4 wpos : Position; //ワールド座標
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
    outData.normal = mul(normal, matNormal);
    
    uv.w = 1; //w成分は0にする
    outData.uv = uv.xy; //UV座標はそのまま
    outData.eyev = eyePosition - outData.wpos; //視線ベクトルを計算して渡す

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
    float4 ambentFactor = { 0.2, 0.2, 0.2, 1.0 };
    float3 dir = normalize(lightPosition.xyz); //ピクセル位置のポリゴンの3次元座標＝wpos
    
    diffuse = diffuseColor * diffusefactor * clamp(dot(inData.normal.xyz, dir), 0, 1);
    float4 color;
    if (useTexture == 1)
    {
        color = diffuse * g_texture.Sample(g_sampler, inData.uv) + ambientColor * ambentFactor; //テクスチャーから色を取得
    }
    else
    {
        color = diffuse + ambientColor * ambentFactor;

    }
    //color = 
    //float4 ret = float4(inData.uv.x, inData.uv.y, 0, 1);
    return color;
}