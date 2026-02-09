//───────────────────────────────────────
// テクスチャ＆サンプラーデータのグローバル変数定義
//───────────────────────────────────────
Texture2D g_texture : register(t0); // ディフューズテクスチャ
SamplerState g_sampler : register(s0); // サンプラー

//───────────────────────────────────────
// コンスタントバッファ
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
    float4 wpos : POSITION0; // ワールド座標
    float4 spos : SV_POSITION; // スクリーン位置
    float2 uv : TEXCOORD; // UV座標
    float4 normal : NORMAL; // 法線ベクトル
    float4 eyev : POSITION1; // 視線ベクトル
};

//───────────────────────────────────────
// 頂点シェーダ
//───────────────────────────────────────
VS_OUT VS(float4 pos : POSITION, float4 uv : TEXCOORD, float4 normal : NORMAL)
{
    VS_OUT outData;

    outData.spos = mul(pos, matWVP);
    outData.wpos = mul(pos, matWorld);

    normal.w = 0;
    outData.normal = mul(normal, matNormal);

    outData.uv = uv.xy;
    outData.eyev = outData.wpos - eyePosition;

    return outData;
}

//───────────────────────────────────────
// ピクセルシェーダ
//───────────────────────────────────────
float4 PS(VS_OUT inData) : SV_Target
{
    float4 diffuse;
    float4 ambientColor = ambient;
    float4 ambientFactor = { 0.2, 0.2, 0.2, 1.0 };
    float3 dir = normalize(lightPosition.xyz - inData.wpos.xyz);
    float dTerm = 1.0;

    // 法線をsin関数で歪めてバンプマップの原理をデモ（法線マップを使わず動的生成）
    float3 N = normalize(inData.normal.xyz);
    // UVのx座標を使ってsin波で法線をオフセット（波状の凹凸をシミュレート）
    //float bumpStrength = 0.5; // 歪みの強さ（調整可能）
    //float frequency = 80.0; // 波の頻度（調整可能）
    //float offsetX = sin(inData.uv.x * frequency) * bumpStrength; // x方向の歪み
    ////float offsetY = sin(inData.uv.y * frequency) * bumpStrength; // y方向の歪み（オプションで追加）
    //N.x += offsetX; // 法線のx成分を歪める
    ////N.y += offsetY; // 法線のy成分を歪める（波を複雑に）
    //N = normalize(N); // 正規化して長さを1に保つ

    diffuse = diffuseColor * diffusefactor * clamp(dot(N, dir), 0, 1) * dTerm;

    float3 L = normalize(lightPosition.xyz - inData.wpos.xyz);
    float ndotl = saturate(dot(N, L));
    float spec = 0.0;
    if (ndotl > 0.0)
    {
        float3 R = reflect(L, N);
        float3 V = normalize(inData.eyev.xyz);
        spec = pow(saturate(dot(R, V)), 32.0) * ndotl;
    }
    float4 specularCol = specular * spec;
    float4 specularTerm = specularCol * dTerm;

    float4 diffuseTerm;
    float4 ambientTerm;
    float4 color;
    if (useTexture == 1)
    {
        diffuseTerm = diffuse * g_texture.Sample(g_sampler, inData.uv);
        ambientTerm = ambientFactor * g_texture.Sample(g_sampler, inData.uv);
    }
    else
    {
        diffuseTerm = diffuse;
        ambientTerm = ambientFactor * diffuseColor;
    }

    color = diffuseTerm + specularTerm + ambientTerm;

    // デバッグ用：歪んだ法線を可視化（コメントアウトを外すと法線が色として表示）
    // color = float4((N.x + 1.0) / 2.0, (N.y + 1.0) / 2.0, (N.z + 1.0) / 2.0, 1.0);

    return color;
}