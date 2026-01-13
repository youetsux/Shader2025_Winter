#pragma once
#include "Engine\\GameObject.h"
#include <windows.h>
#include "Engine\\Sprite.h"

namespace
{
}


class Stage :
    public GameObject
{
public:
	Stage(GameObject *parent);
	~Stage();
	void Initialize() override;
	void Update() override;
	void Draw()override;
	void Release()override;
private:
	Sprite* pMelbourne_;
};

