#include "Stage.h"
#include <string>
#include <vector>
#include "Engine//Model.h"
#include "resource.h"

Stage::Stage(GameObject* parent)
	:GameObject(parent, "Stage"), pMelbourne_(nullptr)
{

}

Stage::~Stage()
{
}

void Stage::Initialize()
{
	pMelbourne_ = new Sprite(L"Assets\\melbourne.png");
}

void Stage::Update()
{
}

void Stage::Draw()
{
	Transform t;
	t.scale_ = { 0.5f, 0.5f, 1.0f };
	t.Calculation();
	XMMATRIX worldMatrix = t.GetWorldMatrix();
	pMelbourne_->Draw(worldMatrix);

}

void Stage::Release()
{
}



